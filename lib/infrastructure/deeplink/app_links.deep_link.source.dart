import 'package:app_links/app_links.dart';
import 'package:songbook/core/domain/services/deep_link.source.dart';

/// Branche [DeepLinkSource] sur `app_links`, qui unifie les Universal Links
/// iOS, les App Links Android et leurs équivalents desktop.
class AppLinksDeepLinkSource implements DeepLinkSource {
  final AppLinks _appLinks;

  /// Le lien de démarrage n'est rendu qu'une fois : `app_links` le conserve
  /// pour toute la vie du processus, et le relire à chaque redémarrage du
  /// gestionnaire rejouerait un abonnement déjà traité.
  bool _initialLinkConsumed = false;

  AppLinksDeepLinkSource([AppLinks? appLinks])
    : _appLinks = appLinks ?? AppLinks();

  @override
  Future<Uri?> initialLink() async {
    if (_initialLinkConsumed) return null;
    _initialLinkConsumed = true;

    return _appLinks.getInitialLink();
  }

  @override
  Stream<Uri> linkStream() => _appLinks.uriLinkStream;
}

/// Source inerte, pour les plateformes et les tests où aucun lien n'arrive.
class NoDeepLinkSource implements DeepLinkSource {
  const NoDeepLinkSource();

  @override
  Future<Uri?> initialLink() async => null;

  @override
  Stream<Uri> linkStream() => const Stream.empty();
}
