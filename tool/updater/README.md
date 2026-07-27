# songbook-updater

Installateur / launcher / **auto-updater silencieux** pour Songbook desktop
(**Windows**, **Linux** & **macOS**).

Sur Windows/Linux, il comble l'absence de store. Sur **macOS**, c'est
l'**unique** canal de distribution (Songbook n'est **pas** sur le Mac App
Store) : l'app y est signée **Developer ID** + **notarisée**, et distribuée en
`.app` zippé — donc aucun sandbox (indispensable pour piloter la fenêtre de MAJ)
ni alerte Gatekeeper.

Un seul binaire Dart compilé natif (`dart compile exe`), attaché à chaque
release GitHub : `songbook-updater-windows.exe`, `songbook-updater-linux`, et —
sur macOS — emballé dans un **`.app` notarisé + staplé** (`Songbook Installer.app`,
zippé dans `songbook-installer-macos-*.zip`) pour passer Gatekeeper au double-clic.

> macOS, deux contraintes de signature à ne pas casser (cf.
> [MACOS_SETUP.md §5](MACOS_SETUP.md#5-points-de-vigilance-si-un-job-macos-échoue),
> points 5 et 6) :
>
> 1. tout est signé avec `macos/Installer.entitlements`
>    (`allow-unsigned-executable-memory`), sans quoi le hardened runtime tue le
>    binaire Dart AOT au démarrage ;
> 2. le `.app` embarque une **seconde copie** du binaire dans
>    `Contents/Resources/songbook-updater`, signée **en autonome** : c'est elle
>    qu'on relocalise dans `<root>/updater/`. L'exécutable principal ne peut pas
>    servir, sa signature étant liée à l'`Info.plist` du bundle.

## Ce qu'il fait

- **Première installation** (seul moment interactif) : on lance le binaire
  téléchargé, il demande le **dossier d'installation** (avec un défaut
  pré-rempli), récupère la dernière release GitHub, l'installe et crée un
  raccourci.
- **Chaque lancement suivant** (via le raccourci) : il vérifie GitHub puis lance
  l'app. **S'il n'y a rien à mettre à jour : aucune fenêtre.** Si une MAJ est
  trouvée, une **fenêtre de progression** s'affiche le temps du
  téléchargement/installation, puis l'app démarre. Réseau lent/absent : l'app
  est lancée directement sur la version locale.
- **Auto-mise à jour de l'updater** lui-même.

La fenêtre est **rendue par l'app Songbook elle-même** (`current/songbook
--updating …`) : une petite fenêtre Flutter (fiable, contrairement à
PowerShell/WinForms), pilotée par fichiers (`.update-status`, `.update-choice`).

Depuis l'app >= 1.5.0, une MAJ trouvée **propose** d'abord
« Mettre à jour / Plus tard / Ignorer cette version » (`--prompt`) :
- **Mettre à jour** : la fenêtre passe en progression, la MAJ s'applique.
- **Plus tard** : on lance la version actuelle ; reproposé au prochain lancement.
- **Ignorer cette version** : mémorisé dans `config.json` (`ignoredVersion`) ;
  reproposé seulement pour une version plus récente.

Garde-fous de version (basés sur la version RÉELLE pointée par `current`, pas sur
`config.json`) : `--updating` >= 1.5.0, `--prompt` >= 1.5.0.

## Layout sur disque

```
<root>/                      racine choisie à l'install
  versions/<v>/              contenu d'une version (songbook.exe + dll + data/, ou AppImage, ou songbook.app)
  current      ->  versions/<v>   jonction (Windows) / symlink (Linux & macOS)
  updater/songbook-updater[.exe]   le binaire relocalisé (cible stable des raccourcis)
                                   macOS : copie issue de Contents/Resources/, pas de Contents/MacOS/
  config.json                { root, installedVersion, lastCheck }
  updater.log                trace (les lancements sont sans console)
  launch.vbs                 (Windows) wrapper de lancement caché
```

Racine par défaut : `%LOCALAPPDATA%\Songbook` (Windows),
`~/.local/share/Songbook` (Linux), `~/Library/Application Support/Songbook`
(macOS).

Le raccourci pointe **toujours** sur `updater/` (jamais sur un exe versionné),
donc il ne casse jamais d'une version à l'autre. La bascule de `current` est
atomique sous Linux/macOS (rename d'un symlink), quasi-atomique sous Windows
(jonction `mklink /J`, sans droits admin ni Mode Développeur).

## Pourquoi aucun verrouillage de fichier

L'updater est un binaire **distinct** de `songbook.exe`, et il met à jour
**avant** de lancer l'app : l'app n'est jamais en cours d'exécution quand on
touche aux fichiers. On n'écrase jamais une version (on en **ajoute** une puis
on bascule le lien), donc rien n'est verrouillé.

## Comment ça démarre sans fenêtre

- **Windows** : le raccourci lance `wscript.exe launch.vbs`, qui exécute
  l'updater en fenêtre cachée (`WshShell.Run …, 0`).
- **Linux** : l'entrée `.desktop` a `Terminal=false`.
- **macOS** : un petit bundle `~/Applications/Songbook.app` (créé à l'install)
  dont l'exécutable est un script `exec updater --launch`. Lancé par
  LaunchServices, il ne fait apparaître **aucun terminal** (un binaire CLI
  double-cliqué, lui, en ouvrirait un). Ce lanceur a un bundle id distinct
  (`fr.dtfh.songbook.launcher`) pour ne pas entrer en conflit avec l'app.

## Commandes

| Commande | Effet |
|---|---|
| (défaut) | Installe si absent, sinon MAJ silencieuse + lance l'app. |
| `--install [--dir <path>] [--yes]` | Installation neuve. `--yes` = non-interactif (dossier par défaut). |
| `--launch [--ui]` | MAJ puis lancement (mode du raccourci). `--ui` : fenêtre de progression si une MAJ est appliquée. |
| `--update` | MAJ silencieuse, sans lancer. |
| `--check` | Affiche version locale vs dernière dispo. |

## Build local

```sh
cd tool/updater
dart pub get
dart compile exe bin/songbook_updater.dart -o songbook-updater
```

Le CI (`.github/workflows/release.yml`) compile et attache les binaires à chaque
release taggée `v*` :
- `build-updater` (matrice **Windows + Linux + macOS** ; sur macOS, étapes
  supplémentaires : l'updater est emballé dans un `.app`, signé Developer ID,
  **notarisé + staplé**, puis zippé) ;
- `build-macos` (l'app macOS elle-même : `.app` Developer ID non-sandboxé,
  notarisé + staplé, zippé via `ditto`).

Ces builds macOS requièrent deux secrets **en plus** de l'App Store Connect :
`DEVELOPER_ID_APPLICATION_P12_BASE64` et `DEVELOPER_ID_APPLICATION_PASSWORD`
(cf. commentaires du workflow).
