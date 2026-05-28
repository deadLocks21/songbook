import 'package:songbook/core/domain/model/recueil.dart';

/// Interface pour récupérer la liste des recueils depuis une source distante.
abstract interface class RemoteRecueilRepository {
  /// Récupère tous les recueils disponibles depuis [baseUrl] (origine de l'API).
  Future<List<Recueil>> fetchRecueils(String baseUrl);
}
