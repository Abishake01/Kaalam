import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../services/voice_service.dart';
import '../services/calendar_service.dart';
import '../services/sleep_advisor.dart';
import '../services/alarm_scheduler.dart';
import '../models/alarm_suggestion.dart';
import 'alarm_confirmation_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _voice = VoiceService();
  final _calendar = CalendarService();
  final _advisor = SleepAdvisor();

  UserProfile? _profile;
  bool _micActive = false;
  String _lastHeard = '';
  AlarmSuggestion? _lastSuggestion;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    AlarmScheduler.initialize();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final age = prefs.getInt('age');
    final prof = prefs.getString('profession');
    if (age != null && prof != null) {
      setState(() => _profile = UserProfile(age: age, profession: prof));
    } else {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/onboarding');
    }
  }

  Future<void> _handlePhrase(String phrase) async {
    setState(() { _lastHeard = phrase; });
    final intent = _voice.matchIntent(phrase);

    switch (intent.type) {
      case VoiceIntentType.goingToSleep:
        await _suggestAndConfirm();
        break;
      case VoiceIntentType.cancelAlarm:
        await AlarmScheduler.cancelAll();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alarm cancelled')));
        break;
      case VoiceIntentType.wakeInHours:
        final h = intent.hours ?? 8;
        final start = DateTime.now();
        final suggestion = AlarmSuggestion(wakeTime: start.add(Duration(hours: h)), totalSleep: Duration(hours: h));
        setState(() => _lastSuggestion = suggestion);
        _showConfirm(suggestion);
        break;
      case VoiceIntentType.unknown:
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Didn\'t catch that. Try: 'I am going to sleep'")));
        break;
    }
  }

  Future<void> _suggestAndConfirm() async {
    if (_profile == null) return;
    final sleepStart = DateTime.now();
    final hasCal = await _calendar.requestPermissions();
    final events = hasCal ? await _calendar.upcomingEventsWithin(window: const Duration(hours: 18)) : <DateTime>[];
    final suggestion = _advisor.suggest(profile: _profile!, sleepStart: sleepStart, nextEvents: events);
    setState(() => _lastSuggestion = suggestion);
    _showConfirm(suggestion);
  }

  void _showConfirm(AlarmSuggestion s) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => AlarmConfirmationSheet(
        suggestion: s,
        onConfirm: (at) async {
          await AlarmScheduler.scheduleAlarm(at: at);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Alarm set for ${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}')),
          );
        },
        onCancel: () async { await AlarmScheduler.cancelAll(); },
      ),
    );
  }

  void _toggleMic() {
    setState(() => _micActive = !_micActive);
    if (_micActive) {
      // Placeholder: simulate voice by prompting text input
      Future.microtask(() async {
        final phrase = await showDialog<String>(
          context: context,
          builder: (ctx) {
            final controller = TextEditingController();
            return AlertDialog(
              title: const Text('Speak (temporary text input)'),
              content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'e.g., I am going to sleep')),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('Send')),
              ],
            );
          },
        );
        setState(() => _micActive = false);
        if (phrase != null && phrase.trim().isNotEmpty) {
          await _handlePhrase(phrase);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profText = _profile == null ? '' : '${_profile!.profession} • ${_profile!.age}y';

    return Scaffold(
      appBar: AppBar(title: const Text('Kaalam')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_profile != null) Text('Profile: $profText'),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(_micActive ? Icons.mic : Icons.mic_none, color: _micActive ? Colors.red : null),
                const SizedBox(width: 8),
                Text(_micActive ? 'Listening…' : 'Tap mic to speak'),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _toggleMic,
              icon: const Icon(Icons.mic),
              label: const Text('Speak to Kaalam'),
            ),
            const SizedBox(height: 16),
            if (_lastHeard.isNotEmpty) Text('Heard: "$_lastHeard"'),
            const Divider(height: 32),
            if (_lastSuggestion != null) ...[
              const Text('Latest Suggestion', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('Wake at: ${_lastSuggestion!.wakeTime}'),
              Text('Sleep: ${_lastSuggestion!.totalSleep.inHours}h ${_lastSuggestion!.totalSleep.inMinutes % 60}m'),
              if (_lastSuggestion!.note != null) Text(_lastSuggestion!.note!, style: const TextStyle(color: Colors.blueGrey)),
              if (_lastSuggestion!.warning) const Text('Warning: healthy sleep may be limited', style: TextStyle(color: Colors.red)),
            ],
            const Spacer(),
            Row(
              children: [
                ElevatedButton.icon(onPressed: _suggestAndConfirm, icon: const Icon(Icons.bedtime), label: const Text('I am going to sleep')),
                const SizedBox(width: 12),
                ElevatedButton.icon(onPressed: () async { await AlarmScheduler.cancelAll(); }, icon: const Icon(Icons.alarm_off), label: const Text('Cancel alarm')),
              ],
            )
          ],
        ),
      ),
    );
  }
}
