enum VoiceIntentType { goingToSleep, cancelAlarm, wakeInHours, unknown }

class VoiceIntent {
  final VoiceIntentType type;
  final int? hours;
  VoiceIntent(this.type, {this.hours});
}

/// Offline intent scaffolding using phrase matching.
/// Replace this with Picovoice/Vosk for robust offline voice.
class VoiceService {
  VoiceIntent matchIntent(String phrase) {
    final p = phrase.toLowerCase().trim();
    if (p.contains("i am going to sleep") || p.contains("going to sleep")) {
      return VoiceIntent(VoiceIntentType.goingToSleep);
    }
    if (p.contains("cancel alarm")) {
      return VoiceIntent(VoiceIntentType.cancelAlarm);
    }
    // e.g., "wake me in eight hours"
    if (p.contains("wake me in") || p.contains("wake in")) {
      final h = _extractHours(p);
      if (h != null) return VoiceIntent(VoiceIntentType.wakeInHours, hours: h);
    }
    return VoiceIntent(VoiceIntentType.unknown);
  }

  int? _extractHours(String p) {
    // Try digits first
    final digitMatch = RegExp(r"(\d{1,2})\s*hour").firstMatch(p);
    if (digitMatch != null) {
      final v = int.tryParse(digitMatch.group(1)!);
      if (v != null) return v;
    }
    // Basic words mapping
    const map = {
      'one': 1,
      'two': 2,
      'three': 3,
      'four': 4,
      'five': 5,
      'six': 6,
      'seven': 7,
      'eight': 8,
      'nine': 9,
      'ten': 10,
    };
    for (final e in map.entries) {
      if (p.contains(e.key) && p.contains('hour')) return e.value;
    }
    return null;
  }
}
