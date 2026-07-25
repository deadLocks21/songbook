import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;

import 'github.dart';
import 'log.dart';
import 'net.dart';

/// Télécharge [asset] dans un fichier temporaire via l'outil HTTP système
/// (cf. [httpDownload] : respecte le magasin de certificats Windows / proxys).
Future<File> downloadAsset(ReleaseAsset asset, String tmpDir, Log log) async {
  Directory(tmpDir).createSync(recursive: true);
  final dest = File(p.join(tmpDir, asset.name));

  log('Téléchargement de ${asset.name} (${asset.size ~/ 1024} Ko)…');
  httpDownload(
    asset.url,
    dest.path,
    headers: {'User-Agent': 'songbook-updater'},
  );
  log('Téléchargé ${asset.name}');
  return dest;
}

/// Installe l'app contenue dans [archiveFile] dans [versionDir].
///  - Windows : décompresse le `.zip` (songbook.exe + dll + data/) à la racine.
///  - macOS   : extrait le `.app` zippé via `ditto` (préserve la signature).
///  - Linux   : place l'AppImage en `Songbook.AppImage` et la rend exécutable.
void installAppArtifact(File archiveFile, String versionDir, Log log) {
  final dir = Directory(versionDir);
  if (dir.existsSync()) dir.deleteSync(recursive: true);
  dir.createSync(recursive: true);

  if (Platform.isWindows) {
    _extractZip(archiveFile.path, versionDir, log);
  } else if (Platform.isMacOS) {
    _extractMacApp(archiveFile.path, versionDir, log);
  } else {
    final target = File(p.join(versionDir, 'Songbook.AppImage'));
    archiveFile.copySync(target.path);
    Process.runSync('chmod', ['+x', target.path]);
    log('AppImage installée : ${target.path}');
  }
}

/// Extrait un `.app` zippé via l'outil système `ditto` (et NON le package Dart
/// `archive`). C'est crucial : `ditto` préserve les symlinks des frameworks, les
/// bits exécutables et les métadonnées, donc la **signature Developer ID / la
/// notarisation survivent** à l'extraction. Le package `archive` aplatirait les
/// symlinks internes du bundle → signature invalidée → Gatekeeper refuserait
/// l'app. (Même philosophie que net.dart : déléguer aux outils système.)
void _extractMacApp(String zipPath, String destDir, Log log) {
  final args = ['-x', '-k', zipPath, destDir];
  final r = Process.runSync('ditto', args);
  if (r.exitCode != 0) {
    throw ProcessException(
      'ditto',
      args,
      (r.stderr as String?) ?? 'ditto a échoué',
      r.exitCode,
    );
  }
  log('Bundle .app extrait dans $destDir');
}

void _extractZip(String zipPath, String destDir, Log log) {
  final input = InputFileStream(zipPath);
  try {
    final archive = ZipDecoder().decodeBuffer(input);
    for (final entry in archive) {
      final outPath = p.join(destDir, entry.name);
      if (entry.isFile) {
        final out = OutputFileStream(outPath);
        try {
          entry.writeContent(out);
        } finally {
          out.closeSync();
        }
      } else {
        Directory(outPath).createSync(recursive: true);
      }
    }
    log('Archive décompressée dans $destDir');
  } finally {
    input.closeSync();
  }
}
