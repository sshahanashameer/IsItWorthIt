import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class CalendarService {
  // Add event to Google Calendar via web link
  // This works on web, Android, and iOS without OAuth!
  static Future<bool> addToGoogleCalendar({
    required String eventName,
    required String description,
    required String location,
    required DateTime startDateTime,
    required DateTime endDateTime,
  }) async {
    try {
      // Format dates for Google Calendar URL
      final dateFormat = DateFormat("yyyyMMdd'T'HHmmss'Z'");
      final startStr = dateFormat.format(startDateTime.toUtc());
      final endStr = dateFormat.format(endDateTime.toUtc());

      // Encode parameters
      final encodedTitle = Uri.encodeComponent(eventName);
      final encodedDesc = Uri.encodeComponent(description);
      final encodedLocation = Uri.encodeComponent(location);

      // Build Google Calendar URL
      final url = 'https://calendar.google.com/calendar/render?'
          'action=TEMPLATE'
          '&text=$encodedTitle'
          '&dates=$startStr/$endStr'
          '&details=$encodedDesc'
          '&location=$encodedLocation'
          '&sf=true'
          '&output=xml';

      final uri = Uri.parse(url);

      // Open the calendar link
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error adding to calendar: $e');
      return false;
    }
  }

  // Generate iCal file content (alternative method)
  static String generateICalContent({
    required String eventName,
    required String description,
    required String location,
    required DateTime startDateTime,
    required DateTime endDateTime,
  }) {
    final dateFormat = DateFormat("yyyyMMdd'T'HHmmss");
    final now = dateFormat.format(DateTime.now());
    final start = dateFormat.format(startDateTime);
    final end = dateFormat.format(endDateTime);

    return '''BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//ODWise//Event Calendar//EN
BEGIN:VEVENT
UID:${DateTime.now().millisecondsSinceEpoch}@odwise.app
DTSTAMP:$now
DTSTART:$start
DTEND:$end
SUMMARY:$eventName
DESCRIPTION:$description
LOCATION:$location
STATUS:CONFIRMED
SEQUENCE:0
BEGIN:VALARM
TRIGGER:-PT24H
DESCRIPTION:Event reminder
ACTION:DISPLAY
END:VALARM
BEGIN:VALARM
TRIGGER:-PT1H
DESCRIPTION:Event starting soon
ACTION:DISPLAY
END:VALARM
END:VEVENT
END:VCALENDAR''';
  }

  // Download .ics file (works on web)
  static Future<void> downloadICalFile({
    required String eventName,
    required String description,
    required String location,
    required DateTime startDateTime,
    required DateTime endDateTime,
  }) async {
    final icalContent = generateICalContent(
      eventName: eventName,
      description: description,
      location: location,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
    );

    // For web: create a data URL and trigger download
    final dataUrl =
        'data:text/calendar;charset=utf-8,${Uri.encodeComponent(icalContent)}';
    final uri = Uri.parse(dataUrl);

    try {
      await launchUrl(uri);
    } catch (e) {
      print('Error downloading calendar file: $e');
    }
  }
}
