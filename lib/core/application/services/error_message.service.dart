import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Service pour transformer les erreurs techniques en messages conviviaux pour l'utilisateur.
/// Ce service analyse les exceptions et retourne des messages compréhensibles
/// tout en gardant les détails techniques dans les logs via debugPrint.
class ErrorMessageService {
  /// Transforme une exception en message convivial pour l'utilisateur.
  /// Utilise debugPrint pour garder une trace technique dans les logs.
  static String getNetworkErrorMessage(Object error) {
    // Garder la trace technique dans les logs
    debugPrint('Erreur technique: $error');

    // Analyser le type d'erreur et retourner un message convivial
    if (error is DioException) {
      return _getDioErrorMessage(error);
    } else if (error is FormatException) {
      return _getFormatErrorMessage(error);
    } else {
      return _getGenericErrorMessage(error);
    }
  }

  /// Vrai si [error] est un `401 invalid_token` (JWT rejeté par le serveur) —
  /// exactement le cas que l'intercepteur traite par purge + retour OTP.
  /// L'appelant ne doit donc pas le présenter comme une erreur réseau.
  static bool isUnauthorized(Object error) {
    if (error is! DioException || error.response?.statusCode != 401) {
      return false;
    }
    final data = error.response?.data;
    return data is Map && data['code'] == 'invalid_token';
  }

  /// Traite spécifiquement les erreurs Dio
  static String _getDioErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Le serveur met trop de temps à répondre. Veuillez réessayer.';

      case DioExceptionType.sendTimeout:
        return 'Impossible d\'envoyer les données au serveur. Vérifiez votre connexion.';

      case DioExceptionType.receiveTimeout:
        return 'Le serveur a mis trop de temps à envoyer les données. Veuillez réessayer.';

      case DioExceptionType.badCertificate:
        return 'Problème de certificat de sécurité. Vérifiez votre connexion.';

      case DioExceptionType.badResponse:
        return _getHttpErrorMessage(error.response?.statusCode);

      case DioExceptionType.cancel:
        return 'La requête a été annulée.';

      case DioExceptionType.connectionError:
        return 'Impossible de se connecter au serveur. Vérifiez votre connexion internet et l\'URL du serveur.';

      case DioExceptionType.unknown:
        // Pour les erreurs inconnues, essayer d'extraire plus d'infos
        if (error.message?.contains('Network is unreachable') ?? false) {
          return 'Réseau inaccessible. Vérifiez votre connexion internet.';
        } else if (error.message?.contains('Failed host lookup') ?? false) {
          return 'Impossible de trouver le serveur. Vérifiez l\'URL du serveur.';
        } else {
          return 'Une erreur réseau inattendue s\'est produite. Veuillez réessayer.';
        }
    }
  }

  /// Traite les erreurs HTTP selon leur code de statut
  static String _getHttpErrorMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'La requête envoyée n\'est pas valide. Vérifiez les paramètres.';
      case 401:
        return 'Accès non autorisé au serveur. Vérifiez vos droits d\'accès.';
      case 403:
        return 'Accès interdit au serveur. Vérifiez vos droits d\'accès.';
      case 404:
        return 'Le serveur est introuvable à cette adresse. Vérifiez l\'URL du serveur.';
      case 408:
        return 'Le serveur a mis trop de temps à répondre. Veuillez réessayer.';
      case 429:
        return 'Trop de requêtes envoyées. Veuillez attendre un moment avant de réessayer.';
      case 500:
        return 'Le serveur rencontre un problème technique. Veuillez réessayer plus tard.';
      case 502:
        return 'Problème de communication avec le serveur. Veuillez réessayer.';
      case 503:
        return 'Le serveur est temporairement indisponible. Veuillez réessayer plus tard.';
      case 504:
        return 'Le serveur met trop de temps à répondre. Veuillez réessayer.';
      default:
        if (statusCode != null && statusCode >= 500) {
          return 'Le serveur rencontre un problème technique. Veuillez réessayer plus tard.';
        } else if (statusCode != null && statusCode >= 400) {
          return 'Erreur dans la requête. Vérifiez l\'URL et vos droits d\'accès.';
        } else {
          return 'Une erreur serveur inattendue s\'est produite.';
        }
    }
  }

  /// Traite les erreurs de formatage (parsing JSON, etc.)
  static String _getFormatErrorMessage(FormatException error) {
    return 'Les données reçues sont invalides. Vérifiez l\'URL du serveur ou contactez le support.';
  }

  /// Traite les erreurs non classifiées
  static String _getGenericErrorMessage(Object error) {
    return 'Une erreur inattendue s\'est produite. Veuillez réessayer.';
  }

  /// Message spécifique pour les erreurs de téléchargement de ressources
  static String getResourceDownloadErrorMessage(Object error) {
    debugPrint('Erreur de téléchargement: $error');

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionError:
          return 'Impossible de télécharger les ressources. Vérifiez votre connexion internet.';
        case DioExceptionType.badResponse:
          return 'Les ressources demandées sont introuvables sur le serveur.';
        default:
          return 'Impossible de télécharger les ressources. Veuillez réessayer.';
      }
    }

    return 'Impossible de télécharger les ressources. Une erreur inattendue s\'est produite.';
  }
}
