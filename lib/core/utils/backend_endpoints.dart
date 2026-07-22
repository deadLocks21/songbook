/// API paths appended to the configured backend origin.
///
/// The stored backend URL is domain-only (see [BackendUrl]); every endpoint
/// path lives here and is combined with that origin via `BackendUrl.join`.
/// Add new endpoints here as the API grows — keeping them in one place means
/// the day a second path is needed, there is a single, obvious home for it.
class BackendEndpoints {
  const BackendEndpoints._();

  /// Catalogue of songs to synchronise.
  static const String songs = '/api/songs';

  /// Collections de chants (recueils) disponibles sur le serveur.
  static const String recueils = '/api/recueils';

  /// Listes de chants de l'utilisateur connecté (lecture et écriture).
  /// Une liste précise s'adresse en suffixant `/{id}`, et son partage
  /// `/{id}/share`.
  static const String songLists = '/api/song-lists';

  /// Échange d'un lien ou d'un code de partage contre un accès en lecture.
  static const String songListSubscribe = '/api/song-lists/subscribe';

  /// Demande d'un code OTP par SMS (public).
  static const String requestOtp = '/api/auth/request-otp';

  /// Vérification d'un code OTP, renvoie le JWT (public).
  static const String verifyOtp = '/api/auth/verify-otp';
}
