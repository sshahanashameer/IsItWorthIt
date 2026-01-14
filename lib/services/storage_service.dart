import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event_model.dart';

class StorageService {
  static const String _eventsKey = 'events';
  static const String _totalODHoursKey = 'total_od_hours';

  // Save events
  static Future<void> saveEvents(List<Event> events) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = events.map((e) => json.encode(e.toJson())).toList();
    await prefs.setStringList(_eventsKey, jsonList);
  }

  // Load events
  static Future<List<Event>> loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_eventsKey) ?? [];
    return jsonList.map((jsonStr) {
      final jsonMap = json.decode(jsonStr);
      return Event.fromJson(jsonMap);
    }).toList();
  }

  // Add event
  static Future<void> addEvent(Event event) async {
    final events = await loadEvents();
    events.add(event);
    await saveEvents(events);
  }

  // Update event
  static Future<void> updateEvent(Event updatedEvent) async {
    final events = await loadEvents();
    final index = events.indexWhere((e) => e.id == updatedEvent.id);
    if (index != -1) {
      events[index] = updatedEvent;
      await saveEvents(events);
    }
  }

  // Delete event
  static Future<void> deleteEvent(String eventId) async {
    final events = await loadEvents();
    events.removeWhere((e) => e.id == eventId);
    await saveEvents(events);
  }

  // Get total used OD hours - FIXED VERSION
  static Future<int> getUsedODHours() async {
    final events = await loadEvents();
    // Use simple iteration instead of fold
    int total = 0;
    for (var event in events) {
      total += event.duration;
    }
    return total;
  }

  // Get total OD hours (default 40)
  static Future<int> getTotalODHours() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_totalODHoursKey) ?? 40;
  }

  // Set total OD hours
  static Future<void> setTotalODHours(int hours) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_totalODHoursKey, hours);
  }

  // Get events by verdict
  static Future<List<Event>> getEventsByVerdict(String verdict) async {
    final events = await loadEvents();
    return events.where((e) => e.verdict == verdict).toList();
  }

  // Get events count by sector
  static Future<Map<String, int>> getEventsBySector() async {
    final events = await loadEvents();
    final sectorMap = <String, int>{};
    for (var event in events) {
      if (event.sector != null) {
        sectorMap[event.sector!] = (sectorMap[event.sector!] ?? 0) + 1;
      }
    }
    return sectorMap;
  }
}
