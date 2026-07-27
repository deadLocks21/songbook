# Canal macOS direct — ce qu'il reste à faire

Le **code** du canal d'auto-update macOS (hors App Store) est écrit et commité
(`feat(updater): ajoute le canal d'auto-update macOS`). Il reste des étapes
**d'infrastructure Apple + CI** que je ne peux pas exécuter à ta place :

1. créer un certificat **Developer ID Application** ;
2. ajouter **2 secrets GitHub** ;
3. déclencher **une release** pour valider les jobs de signature/notarisation ;
4. distribuer l'updater aux utilisateurs mac (une fois).

⚠️ Les deux builds macOS sont dans **`build-gate`** : tant que les secrets ne
sont pas configurés, ils échouent et **bloquent tout le pipeline** — y compris
les publications iOS/Android (cf. §5). **Configure donc les secrets AVANT de
pousser le commit.**

---

## 0. Où tout se passe (rappel du pipeline)

```
commit feat/fix sur main (GitLab)
  └─ semantic-release : bump pubspec.yaml + tag vX.Y.Z (GitLab)
       └─ mirror-to-github : pousse le tag vers deadLocks21/songbook (GitHub)
            └─ GitHub Actions release.yml : build + publish + GitHub Release
                 ├─ build-updater (matrice Win/Linux/macOS) ← macOS : secrets
                 └─ build-macos   (app macOS directe)       ← macOS : secrets
```

**Conséquence : les secrets se configurent sur GitHub** (`deadLocks21/songbook`),
là où tourne `release.yml` — **pas** sur GitLab. C'est le même endroit que tes
secrets `APP_STORE_CONNECT_*` actuels.

---

## 1. Créer le certificat « Developer ID Application »

Ce certificat est **différent** de ceux utilisés pour l'App Store
(« Apple Distribution » / « 3rd Party Mac Developer »). Il sert à signer une app
distribuée **hors** store. Il est **account-wide** : le **même** cert signe l'app
directe **et** le binaire updater.

> Rôle requis : **Account Holder** (ou Admin avec accès aux certificats
> Developer ID) sur le compte Apple Developer.

### Voie A — Xcode (le plus simple)

1. Xcode → **Settings → Accounts** → sélectionne ton équipe → **Manage
   Certificates…**
2. Bouton **+** en bas à gauche → **Developer ID Application**.
3. Le certificat + sa clé privée apparaissent dans **Trousseau d'accès**
   (`login`), catégorie **Mes certificats**.

### Voie B — developer.apple.com

1. Trousseau d'accès → menu → **Assistant de certification → Demander un
   certificat à une autorité…** → génère un CSR (enregistré sur disque).
2. developer.apple.com → **Certificates** → **+** → **Developer ID
   Application** → uploade le CSR → télécharge le `.cer` → double-clic pour
   l'installer dans le trousseau.

### Exporter en `.p12` (dans les deux cas)

Dans **Trousseau d'accès → Mes certificats** :

1. Déplie le certificat « Developer ID Application: … » pour voir **la clé
   privée dessous** (sinon l'export ne contiendra pas la clé → inutilisable).
2. Clic droit sur le certificat → **Exporter…** → format **Échange
   d'informations personnelles (.p12)**.
3. Choisis un **mot de passe d'export** (tu le mettras dans le 2ᵉ secret).

---

## 2. Ajouter les 2 secrets GitHub

Encode le `.p12` en base64 :

```bash
base64 -i developer_id.p12 | pbcopy   # le base64 est maintenant dans le presse-papier
```

Puis, sur **GitHub → `deadLocks21/songbook` → Settings → Secrets and variables →
Actions → New repository secret**, crée :

| Secret | Valeur |
|---|---|
| `DEVELOPER_ID_APPLICATION_P12_BASE64` | le base64 collé ci-dessus |
| `DEVELOPER_ID_APPLICATION_PASSWORD` | le mot de passe d'export du `.p12` |

C'est tout ce qui manque côté secrets : la **notarisation réutilise** ta clé
existante `APP_STORE_CONNECT_KEY_IDENTIFIER` / `APP_STORE_CONNECT_ISSUER_ID` /
`APP_STORE_CONNECT_PRIVATE_KEY`.

---

## 3. Vérifier l'accès notarisation (clé App Store Connect)

`notarytool` utilise la clé App Store Connect déjà présente. Deux points à
vérifier une seule fois :

- **Rôle de la clé** : la clé qui publie sur TestFlight (rôle *App Manager* ou
  *Admin*) fonctionne aussi pour notariser. Si l'auth échoue, c'est le rôle à
  regarder (App Store Connect → Users and Access → Integrations → App Store
  Connect API).
- **Contrat développeur** : si le **Program License Agreement** n'est pas
  accepté (bannière dans developer.apple.com), `notarytool` renvoie une erreur
  d'autorisation. Il faut l'accepter côté web.

---

## 4. Déclencher et valider le build

Le commit `feat` étant conventionnel, dès que tu le **pousses sur `main`
(GitLab)**, `semantic-release` coupe une nouvelle version **mineure** (feat ⇒
`X.(Y+1).0`), et la chaîne va jusqu'à GitHub Actions.

**Ordre conseillé :**

1. Configure d'abord les 2 secrets (§2). **Obligatoire** : sans eux, les jobs
   macOS échouent et tout le pipeline est bloqué (voir ci-dessous).
2. `git push` sur `main`.
3. Suis le run dans **GitHub → Actions → Release**. Regarde en particulier
   `Build Updater (macOS)` (l'entrée macOS de la matrice) et `Build macOS (…)`.

**Politique de blocage :** l'app macOS (`build-macos`) et l'updater
(`build-updater`, matrice qui inclut macOS) sont dans **`build-gate`**. S'ils
échouent, le gate ne passe pas et **`publish-ios` / `publish-android` ne se font
pas non plus** — la release est « tout ou rien ». Corrige la cause (souvent les
secrets ou la signature, cf. §5) puis relance le workflow ; il n'y a pas de
version « à moitié publiée » à rattraper.

> Astuce validation sans couper de version : `release.yml` a un
> `workflow_dispatch`. Tu peux lancer le workflow à la main (Actions → Release →
> Run workflow) une fois le code mirroré sur GitHub — il produit une release de
> test taggée `dispatch-v…`.

---

## 5. Points de vigilance (si un job macOS échoue)

Je n'ai pas pu exécuter le CI de signature. Voici, par ordre de probabilité, où
regarder :

1. **`Build macOS release (non signé)` échoue** — l'étape ajoute
   `CODE_SIGNING_ALLOWED = NO` au `.xcconfig` pour bâtir sans signer, puis on
   re-signe. Si `flutter build macos` refuse quand même de builder faute de
   signature, bascule cette étape sur un `xcodebuild … CODE_SIGNING_ALLOWED=NO`
   explicite (le `.app` est ensuite re-signé pareil).
2. **`codesign --verify` ou la notarisation rejette** — récupère le détail :
   ```bash
   xcrun notarytool log <submission-id> \
     --key <key.p8> --key-id <id> --issuer <issuer>
   ```
   Cause typique : un binaire imbriqué non signé en *hardened runtime*. L'ordre
   « frameworks/dylibs d'abord, bundle ensuite » est déjà en place ; complète la
   liste `find` si un helper particulier remonte.
3. **`notarytool submit` : erreur d'auth** — voir §3 (rôle de la clé + contrat).
4. **L'app notarisée crashe au lancement** — un plugin a besoin d'un allègement
   *hardened runtime* absent : ajoute la clé qui manque dans
   `macos/Runner/DirectRelease.entitlements` (le log de crash indique laquelle).
5. **`Songbook Installer.app` : l'icône rebondit dans le Dock puis plus rien**
   (aucun log, aucun dossier créé) — c'est le **même** problème d'entitlement,
   côté installateur cette fois. Un exécutable `dart compile exe` remappe son
   snapshot AOT en mémoire anonyme exécutable ; sous hardened runtime, le noyau
   le tue avant tout code applicatif. Vérifier :
   ```bash
   codesign -d --entitlements - --xml "Songbook Installer.app" | grep unsigned-executable
   # et, dans ~/Library/Logs/DiagnosticReports/songbook-installer-*.ips :
   #   "signal":"SIGKILL (Code Signature Invalid)", "namespace":"CODESIGNING"
   ```
   Le correctif est `tool/updater/macos/Installer.entitlements`
   (`allow-unsigned-executable-memory` — `allow-jit` seul ne suffit pas), passé
   aux deux `codesign` du job `build-updater`. Le job fait désormais tourner
   `--check` sur le `.app` fraîchement signé pour attraper la régression.

---

## 6. Distribuer aux utilisateurs mac (une fois)

Une fois la release verte, la GitHub Release contient
`songbook-installer-macos-<v>-<run>.zip` — un **`Songbook Installer.app`**
notarisé **et staplé**.

Côté utilisateur, **première fois seulement** :

1. Télécharger `songbook-installer-macos-….zip` et le dézipper (double-clic).
2. **Double-cliquer `Songbook Installer.app`.**

- Comme le `.app` est **staplé**, Gatekeeper le laisse passer au double-clic,
  **sans `xattr`, sans Terminal, même hors-ligne**. (C'est tout l'intérêt du
  `.app` vs un binaire nu, cf. §7.)
- Il installe l'app sous `~/Library/Application Support/Songbook`, crée un
  lanceur **`~/Applications/Songbook.app`**, puis démarre l'app. On peut ensuite
  jeter `Songbook Installer.app`.

**Ensuite**, l'utilisateur lance toujours via `~/Applications/Songbook.app`
(double-clic / Spotlight / Dock) : ça vérifie GitHub, applique une éventuelle
MAJ (fenêtre de progression + prompt), puis démarre — **sans terminal**. L'app
**et** l'updater se mettent à jour tout seuls après ça.

---

## 7. Limites connues (assumées)

- **L'updater est livré en `.app` staplé, pas en binaire nu.** Un exécutable nu
  ne peut pas être « staplé » (seulement `.app`/`.dmg`/`.pkg`), et téléchargé via
  navigateur (quarantaine) il est **tué par Gatekeeper** — le contrôle de
  notarisation en ligne n'est pas honoré de façon fiable pour un CLI lancé depuis
  le Terminal (`zsh: killed`). D'où l'emballage en `.app` staplé. L'auto-MAJ de
  l'updater installé (téléchargement curl, sans quarantaine) extrait le binaire
  interne du `.app`.
- **Universal links absents du build direct** :
  `DirectRelease.entitlements` **omet** `associated-domains` (qui exigerait un
  App ID + profil côté Developer ID). Les liens `https://songbook.dtfh.fr/…` ne
  s'ouvrent pas automatiquement dans le build direct ; le partage in-app reste
  fonctionnel. À compléter si le besoin se confirme.
- **Pas de Mac App Store** : macOS n'est distribué qu'en direct (plus de `.pkg`).
  L'utilisateur télécharge `songbook-installer-macos-<v>-<run>.zip` (le `.app`
  installateur) ; l'app elle-même (`songbook-macos-<v>-<run>.zip`) est récupérée
  par l'updater.

---

## Annexe — récapitulatif « à cocher »

- [ ] Certificat **Developer ID Application** créé et exporté en `.p12` (avec la
      clé privée).
- [ ] Secret GitHub `DEVELOPER_ID_APPLICATION_P12_BASE64`.
- [ ] Secret GitHub `DEVELOPER_ID_APPLICATION_PASSWORD`.
- [ ] Clé App Store Connect : rôle OK + contrat développeur accepté.
- [ ] `git push` du commit `feat` sur `main` → release → jobs macOS verts.
- [ ] `Songbook Installer.app` (dans `songbook-installer-macos-*.zip`) récupéré
      depuis la GitHub Release et testé au double-clic sur un Mac.
