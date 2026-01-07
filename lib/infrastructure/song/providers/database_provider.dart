import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/infrastructure/song/drift/drift_database.dart';

part 'database_provider.g.dart';

/// Provider pour l'instance de la base de données Drift.
/// Utilise le répertoire des documents de l'application pour stocker le fichier SQLite.
@riverpod
Future<AppDatabase> appDatabase(Ref ref) async {
  return AppDatabase();
}
