import 'package:songbook/core/application/dtos/recueil.dto.dart';
import 'package:songbook/core/domain/model/recueil.dart';
import 'package:songbook/core/domain/services/remote_recueil.repository.dart';

/// Implémentation en mémoire du [RemoteRecueilRepository].
/// Utilisée sur le web (CORS) et pour les tests.
class InMemoryRemoteRecueilRepository implements RemoteRecueilRepository {
  InMemoryRemoteRecueilRepository();

  @override
  Future<List<Recueil>> fetchRecueils(String baseUrl) async {
    const jsonList = [
      {
        'id': 'b1b1b1b1-0000-4000-8000-000000000001',
        'code': 'JEM',
        'name': "J'aime l'Éternel",
      },
      {
        'id': 'b1b1b1b1-0000-4000-8000-000000000002',
        'code': 'ASA',
        'name': 'Ailes de la foi',
      },
    ];
    return jsonList
        .map((json) => RecueilDto.fromJson(json).toDomain())
        .toList();
  }
}
