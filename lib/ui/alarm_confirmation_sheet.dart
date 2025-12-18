import 'package:flutter/material.dart';
import '../models/alarm_suggestion.dart';

class AlarmConfirmationSheet extends StatefulWidget {
  final AlarmSuggestion suggestion;
  final void Function(DateTime confirmedAt) onConfirm;
  final VoidCallback onCancel;

  const AlarmConfirmationSheet({
    super.key,
    required this.suggestion,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<AlarmConfirmationSheet> createState() => _AlarmConfirmationSheetState();
}

class _AlarmConfirmationSheetState extends State<AlarmConfirmationSheet> {
  late TimeOfDay _manualTime;

  @override
  void initState() {
    super.initState();
    _manualTime = widget.suggestion.wakeTimeOfDay;
  }

  Future<void> _pickTime() async {
    final res = await showTimePicker(context: context, initialTime: _manualTime);
    if (res != null) setState(() => _manualTime = res);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.suggestion;
    final sleepH = s.totalSleep.inHours;
    final sleepM = s.totalSleep.inMinutes % 60;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.alarm, size: 20),
              const SizedBox(width: 8),
              const Text('Suggested Wake Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text('${s.wakeTime.hour.toString().padLeft(2, '0')}:${s.wakeTime.minute.toString().padLeft(2, '0')}'),
          Text('Total sleep: ${sleepH}h ${sleepM}m'),
          if (s.note != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(s.note!, style: const TextStyle(color: Colors.blueGrey))),
          if (s.warning) const Padding(padding: EdgeInsets.only(top: 8), child: Text('Warning: healthy sleep may be limited', style: TextStyle(color: Colors.red))),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _pickTime,
                icon: const Icon(Icons.edit),
                label: const Text('Adjust time'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  final now = DateTime.now();
                  final confirmed = DateTime(now.year, now.month, now.day, _manualTime.hour, _manualTime.minute);
                  widget.onConfirm(confirmed.isAfter(now) ? confirmed : confirmed.add(const Duration(days: 1)));
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check_circle),
                label: const Text('Confirm'),
              ),
              const SizedBox(width: 12),
              TextButton.icon(onPressed: () { widget.onCancel(); Navigator.pop(context); }, icon: const Icon(Icons.close), label: const Text('Cancel')),
            ],
          )
        ],
      ),
    );
  }
}
