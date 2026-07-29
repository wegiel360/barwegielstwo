String formatOrderTime(String timestamp) {
  try {
    final dt = DateTime.parse(timestamp);
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) return 'przed chwilą';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min temu';
    if (diff.inHours < 24) return '${diff.inHours}h temu';
    return '${dt.day}.${dt.month}.${dt.year}';
  } catch (_) {
    return timestamp;
  }
}

String formatTimeAgo(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inSeconds < 60) return 'przed chwilą';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min temu';
  if (diff.inHours < 24) return '${diff.inHours}h temu';
  return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
}

bool isFresh(String timestamp, {int minutes = 5}) {
  try {
    final dt = DateTime.parse(timestamp);
    return DateTime.now().difference(dt).inMinutes < minutes;
  } catch (_) {
    return false;
  }
}

bool isWarn(String timestamp, {int minutes = 15}) {
  try {
    final dt = DateTime.parse(timestamp);
    final diff = DateTime.now().difference(dt).inMinutes;
    return diff >= minutes && diff <= 30;
  } catch (_) {
    return false;
  }
}

bool isOld(String timestamp, {int minutes = 30}) {
  try {
    final dt = DateTime.parse(timestamp);
    return DateTime.now().difference(dt).inMinutes > minutes;
  } catch (_) {
    return true;
  }
}