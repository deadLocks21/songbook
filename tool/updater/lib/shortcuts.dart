import 'dart:io';

import 'package:path/path.dart' as p;

import 'layout.dart';
import 'log.dart';

/// Crée le(s) raccourci(s) « point d'entrée stable » qui lancent l'updater en
/// mode `--launch` (check + MAJ silencieuse + démarrage de l'app).
///
/// Le raccourci ne pointe JAMAIS sur un exe versionné : il passe par l'updater
/// relocalisé sous `<root>/updater/`, donc il ne casse jamais d'une version à
/// l'autre.
void createShortcuts(Layout layout, Log log) {
  if (Platform.isWindows) {
    _createWindowsShortcuts(layout, log);
  } else if (Platform.isMacOS) {
    _createMacosLauncher(layout, log);
  } else {
    _createLinuxDesktopEntry(layout, log);
  }
}

// ── Windows ─────────────────────────────────────────────────────────────────

void _createWindowsShortcuts(Layout layout, Log log) {
  // Wrapper VBS : lance l'updater fenêtre cachée (window style 0) -> aucun
  // terminal au démarrage. `--ui` : si (et seulement si) une MAJ est trouvée,
  // l'updater affiche lui-même une fenêtre de progression native.
  final vbs =
      '''
Set shell = CreateObject("WScript.Shell")
shell.Run """${layout.updaterExe}"" --launch --ui", 0, False
''';
  File(layout.launchVbs).writeAsStringSync(vbs);

  final ps = r'''
param($vbs, $iconExe, $workDir)
$shell = New-Object -ComObject WScript.Shell
foreach ($dir in @([Environment]::GetFolderPath('Desktop'), [Environment]::GetFolderPath('Programs'))) {
  $lnk = $shell.CreateShortcut((Join-Path $dir 'Songbook.lnk'))
  $lnk.TargetPath = 'wscript.exe'
  $lnk.Arguments = '"' + $vbs + '"'
  $lnk.IconLocation = $iconExe + ',0'
  $lnk.WorkingDirectory = $workDir
  $lnk.Description = 'Songbook'
  $lnk.Save()
}
''';
  final psFile = File(p.join(layout.root, '_mkshortcut.ps1'))
    ..writeAsStringSync(ps);
  try {
    final r = Process.runSync('powershell', [
      '-NoProfile',
      '-ExecutionPolicy',
      'Bypass',
      '-File',
      psFile.path,
      layout.launchVbs,
      layout.appExecutable, // current\songbook.exe -> icône
      layout.root,
    ]);
    if (r.exitCode != 0) {
      log.error('Création des raccourcis Windows', r.stderr);
    } else {
      log('Raccourcis créés (Bureau + Menu Démarrer)');
    }
  } finally {
    if (psFile.existsSync()) psFile.deleteSync();
  }
}

// ── macOS ─────────────────────────────────────────────────────────────────

/// Crée un petit bundle `.app` « lanceur » dans `~/Applications`, dont
/// l'exécutable n'est qu'un script shell qui appelle `updater --launch`.
///
/// C'est l'équivalent macOS du raccourci Windows / de l'entrée `.desktop` Linux :
///  - un binaire CLI double-cliqué ouvrirait le Terminal ; un bundle `.app`
///    lancé par LaunchServices s'exécute SANS fenêtre de terminal ;
///  - il délègue à l'updater relocalisé sous `<root>/updater/` — jamais à une
///    version — donc il ne casse jamais d'une MAJ à l'autre ;
///  - `~/Applications` (par-utilisateur) évite tout besoin de `sudo`, dans le
///    même esprit que la jonction sans droits admin côté Windows.
void _createMacosLauncher(Layout layout, Log log) {
  final home = Platform.environment['HOME'] ?? '.';
  final bundle = Directory(p.join(home, 'Applications', 'Songbook.app'));
  final macosDir = Directory(p.join(bundle.path, 'Contents', 'MacOS'))
    ..createSync(recursive: true);
  final resDir = Directory(p.join(bundle.path, 'Contents', 'Resources'))
    ..createSync(recursive: true);

  // Exécutable du bundle = script shell qui délègue à l'updater. Chemin cité :
  // la racine par défaut contient une espace (« Application Support »).
  final launcher = File(p.join(macosDir.path, 'Songbook'));
  launcher.writeAsStringSync(
    '#!/bin/sh\n'
    'exec "${layout.updaterExe}" --launch\n',
  );
  Process.runSync('chmod', ['+x', launcher.path]);

  // Bundle id distinct de l'app (`fr.dtfh.songbook`) pour ne pas se marcher
  // dessus dans LaunchServices.
  File(p.join(bundle.path, 'Contents', 'Info.plist')).writeAsStringSync('''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleName</key><string>Songbook</string>
	<key>CFBundleDisplayName</key><string>Songbook</string>
	<key>CFBundleIdentifier</key><string>fr.dtfh.songbook.launcher</string>
	<key>CFBundleExecutable</key><string>Songbook</string>
	<key>CFBundlePackageType</key><string>APPL</string>
	<key>CFBundleIconFile</key><string>AppIcon</string>
	<key>CFBundleShortVersionString</key><string>1.0</string>
	<key>CFBundleVersion</key><string>1</string>
	<key>LSMinimumSystemVersion</key><string>10.14</string>
	<key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
''');

  // Icône : reprend celle de l'app pointée par `current` (best-effort).
  final icon = File(
    p.join(
      layout.currentLink,
      'songbook.app',
      'Contents',
      'Resources',
      'AppIcon.icns',
    ),
  );
  if (icon.existsSync()) {
    try {
      icon.copySync(p.join(resDir.path, 'AppIcon.icns'));
    } catch (_) {
      /* best-effort */
    }
  }

  // Rafraîchit le cache d'icône / l'enregistrement LaunchServices (best-effort).
  Process.runSync('touch', [bundle.path]);

  log('Lanceur créé : ${bundle.path}');
}

// ── Linux ───────────────────────────────────────────────────────────────────

void _createLinuxDesktopEntry(Layout layout, Log log) {
  final home = Platform.environment['HOME'] ?? '.';
  final appsDir = Directory(p.join(home, '.local', 'share', 'applications'))
    ..createSync(recursive: true);

  // Terminal=false -> lancement silencieux, sans fenêtre de terminal.
  final desktop =
      '''
[Desktop Entry]
Type=Application
Name=Songbook
Comment=Songbook
Exec="${layout.updaterExe}" --launch
Icon=${layout.appExecutable}
Terminal=false
Categories=Audio;Music;Utility;
''';
  final file = File(p.join(appsDir.path, 'songbook.desktop'));
  file.writeAsStringSync(desktop);
  Process.runSync('chmod', ['+x', file.path]);

  // Petit symlink CLI pratique : `songbook` dans ~/.local/bin.
  final binDir = Directory(p.join(home, '.local', 'bin'));
  if (binDir.existsSync()) {
    final link = Link(p.join(binDir.path, 'songbook'));
    if (link.existsSync()) link.deleteSync();
    try {
      link.createSync(layout.updaterExe);
    } catch (_) {
      /* best-effort */
    }
  }

  log('Entrée de bureau créée : ${file.path}');
}
