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
