// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_link_handler.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(deepLinkSource)
final deepLinkSourceProvider = DeepLinkSourceProvider._();

final class DeepLinkSourceProvider
    extends $FunctionalProvider<DeepLinkSource, DeepLinkSource, DeepLinkSource>
    with $Provider<DeepLinkSource> {
  DeepLinkSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deepLinkSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deepLinkSourceHash();

  @$internal
  @override
  $ProviderElement<DeepLinkSource> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeepLinkSource create(Ref ref) {
    return deepLinkSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeepLinkSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeepLinkSource>(value),
    );
  }
}

String _$deepLinkSourceHash() => r'2e693f3d42126a4b5e3ceba5f33d6a2bb0d65b50';

/// Reçoit les liens de partage et les fait aboutir.
///
/// Deux règles portent tout le reste :
///
/// - **Un lien reçu déconnecté n'est pas perdu.** Il est mis de côté, le flux
///   OTP se déroule, et l'abonnement reprend tout seul à l'arrivée. Sans cela,
///   le cas le plus courant — on clique un lien, l'app s'ouvre sur l'écran de
///   connexion — obligerait à retrouver le message et à recliquer.
/// - **Un lien d'une autre instance est refusé explicitement.** L'URL du
///   backend est saisie par l'utilisateur : un lien émis ailleurs pointe une
///   autre base de comptes, le jeton n'y voudra rien dire.

@ProviderFor(ShareLinkHandler)
final shareLinkHandlerProvider = ShareLinkHandlerProvider._();

/// Reçoit les liens de partage et les fait aboutir.
///
/// Deux règles portent tout le reste :
///
/// - **Un lien reçu déconnecté n'est pas perdu.** Il est mis de côté, le flux
///   OTP se déroule, et l'abonnement reprend tout seul à l'arrivée. Sans cela,
///   le cas le plus courant — on clique un lien, l'app s'ouvre sur l'écran de
///   connexion — obligerait à retrouver le message et à recliquer.
/// - **Un lien d'une autre instance est refusé explicitement.** L'URL du
///   backend est saisie par l'utilisateur : un lien émis ailleurs pointe une
///   autre base de comptes, le jeton n'y voudra rien dire.
final class ShareLinkHandlerProvider
    extends $NotifierProvider<ShareLinkHandler, ShareLinkEvent?> {
  /// Reçoit les liens de partage et les fait aboutir.
  ///
  /// Deux règles portent tout le reste :
  ///
  /// - **Un lien reçu déconnecté n'est pas perdu.** Il est mis de côté, le flux
  ///   OTP se déroule, et l'abonnement reprend tout seul à l'arrivée. Sans cela,
  ///   le cas le plus courant — on clique un lien, l'app s'ouvre sur l'écran de
  ///   connexion — obligerait à retrouver le message et à recliquer.
  /// - **Un lien d'une autre instance est refusé explicitement.** L'URL du
  ///   backend est saisie par l'utilisateur : un lien émis ailleurs pointe une
  ///   autre base de comptes, le jeton n'y voudra rien dire.
  ShareLinkHandlerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shareLinkHandlerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shareLinkHandlerHash();

  @$internal
  @override
  ShareLinkHandler create() => ShareLinkHandler();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShareLinkEvent? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShareLinkEvent?>(value),
    );
  }
}

String _$shareLinkHandlerHash() => r'3887913c388c139108352f17350b6b1975afc57a';

/// Reçoit les liens de partage et les fait aboutir.
///
/// Deux règles portent tout le reste :
///
/// - **Un lien reçu déconnecté n'est pas perdu.** Il est mis de côté, le flux
///   OTP se déroule, et l'abonnement reprend tout seul à l'arrivée. Sans cela,
///   le cas le plus courant — on clique un lien, l'app s'ouvre sur l'écran de
///   connexion — obligerait à retrouver le message et à recliquer.
/// - **Un lien d'une autre instance est refusé explicitement.** L'URL du
///   backend est saisie par l'utilisateur : un lien émis ailleurs pointe une
///   autre base de comptes, le jeton n'y voudra rien dire.

abstract class _$ShareLinkHandler extends $Notifier<ShareLinkEvent?> {
  ShareLinkEvent? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ShareLinkEvent?, ShareLinkEvent?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ShareLinkEvent?, ShareLinkEvent?>,
              ShareLinkEvent?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
