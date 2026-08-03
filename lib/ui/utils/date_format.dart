const weekDays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
const months = [
  'jan',
  'fév',
  'mar',
  'avr',
  'mai',
  'juin',
  'juil',
  'août',
  'sep',
  'oct',
  'nov',
  'déc',
];

String formatDate(DateTime dt) {
  final day = weekDays[dt.weekday - 1];
  final month = months[dt.month - 1];
  final hour = dt.hour.toString().padLeft(2, '0');
  final minute = dt.minute.toString().padLeft(2, '0');
  return '$day ${dt.day} $month ${dt.year}, $hour:$minute';
}

/// « Dim 9 août », l'année en plus quand ce n'est pas celle en cours.
///
/// Sans heure : pour dire quand un chant a été pris, la minute n'apprend rien.
String formatShortDate(DateTime dt, {DateTime? now}) {
  final day = weekDays[dt.weekday - 1];
  final month = months[dt.month - 1];
  final currentYear = (now ?? DateTime.now()).year;
  final year = dt.year == currentYear ? '' : ' ${dt.year}';
  return '$day ${dt.day} $month$year';
}

/// « aujourd'hui », « hier », « il y a 3 semaines », « il y a 2 ans »…
///
/// Une distance se lit sans compter, là où une date demande de faire la
/// soustraction soi-même : c'est elle qui dit si un chant a assez reposé.
String formatRelativePast(DateTime dt, {DateTime? now}) {
  final days = _daysBetween(dt, now ?? DateTime.now());

  if (days <= 0) return "aujourd'hui";
  if (days == 1) return 'hier';
  if (days < 7) return 'il y a $days jours';
  if (days < 14) return 'il y a une semaine';
  if (days < 60) return 'il y a ${days ~/ 7} semaines';

  final monthCount = _monthsBetween(dt, now ?? DateTime.now());
  if (monthCount < 24) return 'il y a $monthCount mois';
  return 'il y a ${monthCount ~/ 12} ans';
}

/// Nombre de jours calendaires entre deux dates.
///
/// Les composantes sont recollées en UTC avant la soustraction : un changement
/// d'heure fait des journées de 23 ou 25 heures, dont `inDays` mangerait le
/// reste.
int _daysBetween(DateTime from, DateTime to) {
  final start = DateTime.utc(from.year, from.month, from.day);
  final end = DateTime.utc(to.year, to.month, to.day);
  return end.difference(start).inDays;
}

/// Nombre de mois révolus entre deux dates.
int _monthsBetween(DateTime from, DateTime to) {
  final elapsed = (to.year - from.year) * 12 + to.month - from.month;
  return to.day < from.day ? elapsed - 1 : elapsed;
}
