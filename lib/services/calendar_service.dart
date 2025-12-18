import 'package:device_calendar/device_calendar.dart';

class CalendarService {
  final DeviceCalendarPlugin _calendar = DeviceCalendarPlugin();

  Future<bool> requestPermissions() async {
    final res = await _calendar.requestPermissions();
    return res.isGranted;
  }

  Future<List<DateTime>> upcomingEventsWithin({
    Duration window = const Duration(hours: 18),
  }) async {
    final calendarsRes = await _calendar.retrieveCalendars();
    if (calendarsRes.isSuccess && calendarsRes.data != null) {
      final now = DateTime.now();
      final until = now.add(window);
      final eventTimes = <DateTime>[];

      for (final cal in calendarsRes.data!) {
        final eventsRes = await _calendar.retrieveEvents(cal.id!, RetrieveEventsParams(startDate: now, endDate: until));
        if (eventsRes.isSuccess && eventsRes.data != null) {
          for (final e in eventsRes.data!) {
            if (e.start != null) {
              eventTimes.add(e.start!);
            }
          }
        }
      }
      eventTimes.sort();
      return eventTimes;
    }
    return [];
  }
}
