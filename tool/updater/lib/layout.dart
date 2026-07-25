import 'dart:io';

import 'package:path/path.dart' as p;

/// Décrit l'arborescence d'une installation Songbook enracinée en [root] :
///
/// ```
/// <root>/
///   versions/<v>/        contenu d'une version (songbook.exe + dll + data/, ou AppImage)
///   current              jonction (Windows) / symlink (Linux) -> versions/<v>
///   updater/             le binaire updater relocalisé (emplacement stable)
///   config.json          { root, installedVersion, ... }
///   updater.log
///   launch.vbs           (Windows) wrapper de lancement caché
/// ```
class Layout {
  Layout(this.root);

  final String root;

  /// Dépôt GitHub public hébergeant les releases.
  static const repoOwner = 'deadLocks21';
  static const repoName = 'songbook';

  /// Racine d'installation proposée par défaut (modifiable à l'install).
  static String defaultRoot() {
    if (Platform.isWindows) {
      final local =
          _env('LOCALAPPDATA') ??
          p.join(_env('USERPROFILE') ?? r'C:\', 'AppData', 'Local');
      return p.join(local, 'Songbook');
    }
    if (Platform.isMacOS) {
      // Équivalent macOS de %LOCALAPPDATA% / ~/.local/share : les données
      // applicatives par-utilisateur vivent sous ~/Library/Application Support.
      return p.join(
        _env('HOME') ?? '.',
        'Library',
        'Application Support',
        'Songbook',
      );
    }
    final xdg = _env('XDG_DATA_HOME');
    final base = (xdg != null && xdg.isNotEmpty)
        ? xdg
        : p.join(_env('HOME') ?? '.', '.local', 'share');
    return p.join(base, 'Songbook');
  }

  String get versionsDir => p.join(root, 'versions');
  String get currentLink => p.join(root, 'current');
  String get updaterDir => p.join(root, 'updater');
  String get configFile => p.join(root, 'config.json');
  String get logFile => p.join(root, 'updater.log');
  String get launchVbs => p.join(root, 'launch.vbs');

  String versionDir(String version) => p.join(versionsDir, version);

  /// Nom du binaire updater une fois relocalisé sous `<root>/updater/`.
  String get updaterExe => p.join(
    updaterDir,
    Platform.isWindows ? 'songbook-updater.exe' : 'songbook-updater',
  );

  /// Exécutable de l'app à lancer, via le lien `current` (jamais versionné).
  String get appExecutable {
    if (Platform.isWindows) return p.join(currentLink, 'songbook.exe');
    if (Platform.isMacOS) {
      // On vise le binaire INTERNE du bundle (et non `open Songbook.app`) : ça
      // donne un vrai handle de process, indispensable à la fenêtre de MAJ
      // (ProgressWindow détecte la fermeture via exitCode et fait kill()), et ça
      // garde les mêmes sémantiques Process.start(...) que Windows/Linux.
      // `songbook.app` / `songbook` suivent PRODUCT_NAME (macos/.../AppInfo.xcconfig).
      return p.join(
        currentLink,
        'songbook.app',
        'Contents',
        'MacOS',
        'songbook',
      );
    }
    return p.join(currentLink, 'Songbook.AppImage');
  }

  bool get isInstalled => File(configFile).existsSync();

  // ── Découverte d'une install existante ───────────────────────────────────

  /// Fichier-pointeur hors-racine, qui mémorise OÙ Songbook est installé.
  /// Permet à un updater fraîchement téléchargé (dans Téléchargements) de
  /// retrouver l'install existante au lieu de relancer une installation.
  static String pointerFile() {
    if (Platform.isWindows) {
      final appData =
          _env('APPDATA') ??
          p.join(_env('USERPROFILE') ?? r'C:\', 'AppData', 'Roaming');
      return p.join(appData, 'Songbook', 'install.path');
    }
    if (Platform.isMacOS) {
      // Emplacement FIXE (indépendant de la racine choisie) : un updater
      // fraîchement téléchargé dans ~/Downloads y retrouve l'install existante.
      // macOS n'ayant pas la séparation XDG data/config, on le range à côté du
      // reste sous Application Support.
      return p.join(
        _env('HOME') ?? '.',
        'Library',
        'Application Support',
        'Songbook',
        'install.path',
      );
    }
    final xdg = _env('XDG_CONFIG_HOME');
    final base = (xdg != null && xdg.isNotEmpty)
        ? xdg
        : p.join(_env('HOME') ?? '.', '.config');
    return p.join(base, 'songbook', 'install.path');
  }

  /// Résout une installation existante, dans l'ordre :
  ///  1. la racine déduite de l'emplacement du binaire (`<root>/updater/exe`) ;
  ///  2. la racine mémorisée dans le fichier-pointeur.
  /// Retourne `null` si aucune install valide n'est trouvée.
  static Layout? resolveExisting() {
    // 1. binaire exécuté depuis `<root>/updater/` ?
    final exeDir = p.dirname(Platform.resolvedExecutable);
    if (p.basename(exeDir) == 'updater') {
      final candidate = Layout(p.dirname(exeDir));
      if (candidate.isInstalled) return candidate;
    }
    // 2. fichier-pointeur
    final pointer = File(pointerFile());
    if (pointer.existsSync()) {
      final root = pointer.readAsStringSync().trim();
      if (root.isNotEmpty) {
        final candidate = Layout(root);
        if (candidate.isInstalled) return candidate;
      }
    }
    return null;
  }

  void writePointer() {
    final f = File(pointerFile());
    f.parent.createSync(recursive: true);
    f.writeAsStringSync(root);
  }

  static String? _env(String key) => Platform.environment[key];
}
