# Kaalam — Smart Health-Aware Alarm Assistant

Kaalam is a mobile app that sets healthy, context-aware alarms automatically. Say “Hey Kaalam, I am going to sleep” and it will suggest a wake-up time (e.g., 6:05 or 7:25) aligned with healthy sleep, your calendar, and natural wake variability. You can confirm, modify, or cancel before finalizing.

## Features
- Voice-first flow with offline core commands: “I am going to sleep”, “Cancel alarm”, “Wake me in eight hours”.
- Health-aware sleep duration (generally 7–8 hours; age/profession-adjusted).
- Calendar-aware adjustments with meeting previews at wake-up.
- Confirmation and manual override for trust and control.
- Local processing priority; online mode can enhance accuracy when available.

## Project Structure
- `lib/main.dart`: App entry, notifications + timezone init.
- `lib/models/`: `UserProfile`, `AlarmSuggestion`.
- `lib/services/`: `SleepAdvisor`, `AlarmScheduler`, `CalendarService`, `VoiceService`.
- `lib/ui/`: Onboarding, Home, Alarm confirmation UI.

## Setup
1. Install Flutter SDK (3.22+ recommended): https://docs.flutter.dev/get-started/install
2. In this folder:

```bash
flutter pub get
flutter run
```

### Android
- Enable exact alarms on Android 12+ (SCHEDULE_EXACT_ALARM). The `flutter_local_notifications` plugin handles scheduling; you may need to manually allow exact alarms in system settings.
- Microphone and calendar permissions are requested at runtime.

### iOS
- Ensure required privacy keys in `Info.plist`:
  - `NSMicrophoneUsageDescription`
  - `NSCalendarsUsageDescription`
  - `NSUserTrackingUsageDescription` (if adding analytics)

## Offline Voice Commands
This app ships with an intent scaffolding that matches on-device recognized phrases. For full offline STT/NLU, integrate one of:
- Picovoice (Porcupine – wake word; Rhino – intents): https://picovoice.ai/
- Vosk (offline speech recognition): https://github.com/alphacep/vosk-api

Recommended: start with a press-to-speak mic button (offline intent matching included), then add “Hey Kaalam” wake word via Porcupine.

## Calendar Integration
The app reads events (with permission) using `device_calendar`. Kaalam adjusts wake time when early events exist and warns if healthy sleep is infeasible.

## Privacy
- Core commands processed locally whenever possible.
- Microphone usage clearly indicated in UI; recording only during active commands.
- Calendar access is optional and revocable.

## Try It
- Open the app.
- Complete onboarding (age + profession).
- Tap the mic and say: “I am going to sleep”.
- Review the suggested wake time, confirm, or set a manual override.
- Later, say: “Cancel alarm” to clear.

## Next Enhancements
- Add Picovoice (offline wake word + intents).
- Improve profession-based sleep heuristics.
- Add multi-alarm support and recurring schedules.
