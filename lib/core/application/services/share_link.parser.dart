import 'package:songbook/core/utils/backend_url.dart';

/// Ce qu'une URL entrante s'avère être.
sealed class ShareLinkTarget {
  const ShareLinkTarget();
}

/// Un lien de partage exploitable, pour l'instance que l'app interroge.
class ShareLinkInvite extends ShareLinkTarget {
  final String token;

  const ShareLinkInvite(this.token);
}

/// Un lien de partage émis par **une autre instance** que celle configurée.
///
/// Ce n'est pas rattrapable : chaque instance a sa propre base de comptes et de
/// listes, le jeton n'y voudra rien dire. Mieux vaut le dire que d'échouer sur
/// un « lien invalide » trompeur.
class ShareLinkForeignOrigin extends ShareLinkTarget {
  final String origin;

  const ShareLinkForeignOrigin(this.origin);
}

/// Une URL qui n'est pas un lien de partage. Rien à faire, rien à signaler.
class ShareLinkIrrelevant extends ShareLinkTarget {
  const ShareLinkIrrelevant();
}

/// Reconnaît les liens de partage `{origine}/l/{token}` parmi les URL que le
/// système fait remonter à l'app.
///
/// Purement décisionnel : ne touche ni au réseau ni au stockage, pour que la
/// règle d'origine — la seule subtile — soit vérifiable sans rien monter.
class ShareLinkParser {
  const ShareLinkParser._();

  /// Segment de chemin identifiant un lien de partage, côté API.
  static const String _pathSegment = 'l';

  /// Large mais borné : le jeton fait 26 caractères aujourd'hui, et refuser
  /// tout de suite une chaîne aberrante évite un aller-retour serveur inutile.
  static const int _maxTokenLength = 64;

  /// [backendUrl] est l'origine que l'app interroge, telle que l'utilisateur
  /// l'a configurée. Absente, vide ou en mode démo, il n'y a pas d'origine à
  /// comparer : on laisse passer, et la suite du flux dira que le jeton ne mène
  /// à rien — ce qui est vrai, et plus juste que d'accuser l'expéditeur.
  static ShareLinkTarget parse(Uri uri, {String? backendUrl}) {
    final token = _tokenIn(uri);
    if (token == null) return const ShareLinkIrrelevant();

    if (!_matchesConfiguredBackend(uri, backendUrl)) {
      return ShareLinkForeignOrigin(_originOf(uri));
    }

    return ShareLinkInvite(token);
  }

  static String? _tokenIn(Uri uri) {
    final segments = uri.pathSegments;
    if (segments.length != 2 || segments.first != _pathSegment) return null;

    final token = segments.last.trim();
    if (token.isEmpty || token.length > _maxTokenLength) return null;

    return token;
  }

  static bool _matchesConfiguredBackend(Uri uri, String? backendUrl) {
    if (BackendUrl.isInMemoryUrl(backendUrl)) return true;

    final configured = Uri.tryParse(BackendUrl.normalize(backendUrl!));
    if (configured == null) return true;

    // Le port compte : deux instances peuvent cohabiter sur un même hôte, et
    // le schéma aussi — un lien en clair vers un backend en HTTPS n'est pas le
    // même service.
    return uri.host.toLowerCase() == configured.host.toLowerCase() &&
        uri.scheme.toLowerCase() == configured.scheme.toLowerCase() &&
        uri.port == configured.port;
  }

  static String _originOf(Uri uri) => uri.hasPort
      ? '${uri.scheme}://${uri.host}:${uri.port}'
      : '${uri.scheme}://${uri.host}';
}
