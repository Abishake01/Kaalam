import 'dart:math';

import 'package:intl/intl.dart';
import '../models/user_profile.dart';
import '../models/alarm_suggestion.dart';

class SleepAdvisor {
  /// Returns the target healthy sleep duration based on age/profession.
  /// Default: 7–8 hours. Teens: 8–10, older adults: ~7–8. Shift work may reduce target.
  Duration targetSleep(UserProfile profile) {
    final age = profile.age;
    final prof = profile.profession.toLowerCase();

    if (age < 18) return const Duration(hours: 9); // teens
    if (age >= 65) return const Duration(hours: 7, minutes: 30);

    // Simple profession heuristics
    if (prof.contains('nurse') || prof.contains('shift') || prof.contains('factory')) {
      return const Duration(hours: 7);
    }
    if (prof.contains('student')) return const Duration(hours: 8);

    return const Duration(hours: 7, minutes: 30);
  }

  /// Calculate a suggested wake time given sleep start and calendar constraints.
  /// [nextEvents]: list of DateTime for upcoming events today/tomorrow.
  AlarmSuggestion suggest({
    required UserProfile profile,
    required DateTime sleepStart,
    required List<DateTime> nextEvents,
    Duration preparationLead = const Duration(minutes: 45),
  }) {
    final base = targetSleep(profile);

    // Natural variance: 5–25 minutes
    final varianceMinutes = 5 + Random().nextInt(21);
    final baseWake = sleepStart.add(base).add(Duration(minutes: varianceMinutes));

    DateTime? earliestEvent;
    for (final dt in nextEvents) {
      if (dt.isAfter(sleepStart) && (earliestEvent == null || dt.isBefore(earliestEvent!))) {
        earliestEvent = dt;
      }
    }

    var note = '';
    var warning = false;
    var wakeTime = baseWake;

    if (earliestEvent != null) {
      final mustWakeBy = earliestEvent!.subtract(preparationLead);
      if (wakeTime.isAfter(mustWakeBy)) {
        // Adjust earlier to meet event prep time
        wakeTime = mustWakeBy;
        note = 'Adjusted for ${DateFormat('EEE, MMM d • h:mm a').format(earliestEvent!)}';
      }

      // Warn if achievable sleep < 6h due to event
      final achievableSleep = wakeTime.difference(sleepStart);
      if (achievableSleep < const Duration(hours: 6)) {
        warning = true;
        note = note.isEmpty ? 'Healthy sleep unlikely before early event' : '$note; limited sleep';
      }
    }

    final totalSleep = wakeTime.difference(sleepStart);
    return AlarmSuggestion(wakeTime: wakeTime, totalSleep: totalSleep, note: note.isEmpty ? null : note, warning: warning);
  }
}
