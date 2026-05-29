/// Helpers around the configured backend URL.
///
/// The stored backend URL must be an **origin** only — scheme + host + an
/// optional non-default port, with no path/query/fragment. API paths are
/// appended in code at the call sites (see [BackendEndpoints]) via [join], so
/// new endpoints can be added without touching the stored value.
class BackendUrl {
  const BackendUrl._();

  /// Valeur sentinelle qui, saisie comme URL serveur, force les implémentations
  /// en mémoire (données factices, ni réseau ni disque) : mode démo/dev sans
  /// backend. Cf. `inMemoryModeProvider`.
  static const String memorySentinel = 'memory';

  /// Vrai quand [backendUrl] désigne le mode « en mémoire » : valeur absente /
  /// vide, ou égale à la sentinelle [memorySentinel]. Le cas web est traité à
  /// part (cf. `inMemoryModeProvider`).
  static bool isInMemoryUrl(String? backendUrl) {
    final trimmed = backendUrl?.trim() ?? '';
    return trimmed.isEmpty || trimmed == memorySentinel;
  }

  /// Normalises [input] to its origin (`scheme://host[:port]`), dropping any
  /// path, query, fragment and trailing slash. Returns the trimmed input
  /// unchanged when it cannot be parsed as an `http`/`https` URL with a host,
  /// so a malformed value is never silently turned into something else.
  static String normalize(String input) {
    final trimmed = input.trim();
    final uri = Uri.tryParse(trimmed);
    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      return trimmed;
    }
    // Uri elides the port when it matches the scheme default (80/443), so a
    // custom port is preserved while the common case stays clean.
    return Uri(scheme: uri.scheme, host: uri.host, port: uri.port).toString();
  }

  /// Validates a user-entered backend URL. Returns `null` when it is a valid
  /// domain-only URL, otherwise a short French message explaining the problem.
  static String? validate(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return 'L\'URL ne peut pas être vide';
    }
    if (trimmed == memorySentinel) {
      // Sentinelle de démo : acceptée telle quelle (cf. [memorySentinel]).
      return null;
    }
    final uri = Uri.tryParse(trimmed);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return 'Entrez une URL valide commençant par http:// ou https://';
    }
    if (uri.host.isEmpty) {
      return 'L\'URL doit contenir un nom de domaine';
    }
    final hasPath = uri.path.isNotEmpty && uri.path != '/';
    if (hasPath || uri.hasQuery || uri.hasFragment) {
      return 'Saisissez uniquement le domaine, sans chemin '
          '(ex : https://songbook.dtfh.fr)';
    }
    return null;
  }

  /// Joins a backend origin with an API [path], collapsing the slash between
  /// them so `join('https://x.fr/', 'api/songs')` and
  /// `join('https://x.fr', '/api/songs')` both yield `https://x.fr/api/songs`.
  static String join(String base, String path) {
    final origin = base.endsWith('/')
        ? base.substring(0, base.length - 1)
        : base;
    final suffix = path.startsWith('/') ? path : '/$path';
    return '$origin$suffix';
  }
}
