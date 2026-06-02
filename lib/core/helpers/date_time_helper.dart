import 'package:flutter/material.dart';

String formatDate(DateTime date) {
  final now = DateTime.now();
  if (date.year == now.year && date.month == now.month && date.day == now.day) {
    return 'Today';
  } else if (date.year == now.year &&
      date.month == now.month &&
      date.day == now.day - 1) {
    return 'Yesterday';
  } else {
    return '${date.day}/${date.month}/${date.year}';  //12/09/2026
  }
}

String formatRelativeTime(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inSeconds < 60) return 'a few seconds ago';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min';
  if (diff.inHours < 24) return '${diff.inHours} hr';
  return '${diff.inDays} days';     // 3 days ago
}

String formatDateTime(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '${dateTime.day}-${dateTime.month}-${dateTime.year} $hour:$minute';  // 12-09-2026 14:30
}

String formatTime(TimeOfDay timeOfDay) {
  final hour = timeOfDay.hour.toString().padLeft(2, '0');
  final minute = timeOfDay.minute.toString().padLeft(2, '0');
  return '$hour:$minute';  // 14:30
}
