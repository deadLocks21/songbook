/// Ce que les listes de chants disent d'un chant : quand il a déjà été pris,
/// et quand il est déjà prévu.
///
/// Sert à ne pas reprendre toujours les mêmes : au moment de composer une
/// liste, la dernière date répond à « on ne l'a pas chanté il y a trois
/// semaines, déjà ? », et une date à venir prévient qu'il est déjà programmé
/// ailleurs.
///
/// Les dates sont lues comme des heures « au mur », pas comme des instants :
/// une liste venue du serveur porte une étiquette UTC (cf. `RemoteSongListDto`)
/// que l'app n'applique jamais à l'affichage. La comparer telle quelle à
/// maintenant ferait basculer une liste du matin dans le passé avec quelques
/// heures de retard, selon le fuseau.
class SongSchedule {
  /// Dates déjà passées, la plus récente d'abord.
  final List<DateTime> past;

  /// Dates à venir, la plus proche d'abord.
  final List<DateTime> upcoming;

  const SongSchedule({this.past = const [], this.upcoming = const []});

  /// Un chant qu'aucune liste ne mentionne.
  static const never = SongSchedule();

  /// La dernière fois que ce chant a été pris, s'il l'a déjà été.
  DateTime? get lastSungAt => past.isEmpty ? null : past.first;

  /// La prochaine fois où il est déjà prévu, le cas échéant.
  DateTime? get nextPlannedAt => upcoming.isEmpty ? null : upcoming.first;

  bool get isEmpty => past.isEmpty && upcoming.isEmpty;

  /// Répartit [dates] de part et d'autre de [now].
  ///
  /// Les doublons sont écartés : un même chant peut figurer deux fois dans une
  /// liste, ça ne fait pas deux dates.
  factory SongSchedule.from(Iterable<DateTime> dates, {required DateTime now}) {
    final reference = wallClock(now);
    final past = <DateTime>{};
    final upcoming = <DateTime>{};

    for (final date in dates) {
      final at = wallClock(date);
      (at.isAfter(reference) ? upcoming : past).add(at);
    }

    return SongSchedule(
      past: past.toList()..sort((a, b) => b.compareTo(a)),
      upcoming: upcoming.toList()..sort(),
    );
  }

  /// La date telle qu'elle s'affiche, ramenée dans le fuseau de l'appareil.
  ///
  /// Deux dates qui s'affichent pareil deviennent ainsi égales, et comparables
  /// à maintenant sans que le fuseau ne s'en mêle. Les secondes tombent : une
  /// liste est programmée à la minute.
  static DateTime wallClock(DateTime dateTime) => DateTime(
    dateTime.year,
    dateTime.month,
    dateTime.day,
    dateTime.hour,
    dateTime.minute,
  );
}
