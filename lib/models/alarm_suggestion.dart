import 'package:flutter/material.dart';

class AlarmSuggestion {
  final DateTime wakeTime;
  final Duration totalSleep;
  final String? note; // e.g., 'Early meeting at 8:30, adjusted wake time'
  final bool warning; // true if healthy sleep is infeasible

  const AlarmSuggestion({
    required this.wakeTime,
    required this.totalSleep,
    this.note,
    this.warning = false,
  });

  TimeOfDay get wakeTimeOfDay => TimeOfDay(hour: wakeTime.hour, minute: wakeTime.minute);
}
