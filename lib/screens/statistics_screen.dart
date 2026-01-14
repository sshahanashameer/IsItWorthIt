import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/storage_service.dart';
import 'event_detail_screen.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<Event> events = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    final loadedEvents = await StorageService.loadEvents();
    setState(() {
      events = loadedEvents;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Statistics')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final totalEvents = events.length;
    final totalHours = events.fold(0, (sum, e) => sum + e.duration);
    final avgScore = events.where((e) => e.worthItScore != null).isEmpty
        ? 0
        : (events
                    .where((e) => e.worthItScore != null)
                    .fold(0, (sum, e) => sum + e.worthItScore!) /
                events.where((e) => e.worthItScore != null).length)
            .round();

    final sectorCounts = <String, int>{};
    for (var event in events) {
      if (event.sector != null) {
        sectorCounts[event.sector!] = (sectorCounts[event.sector!] ?? 0) + 1;
      }
    }

    final verdictCounts = <String, int>{};
    for (var event in events) {
      if (event.verdict != null) {
        verdictCounts[event.verdict!] =
            (verdictCounts[event.verdict!] ?? 0) + 1;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics & All Events'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Summary Stats
          Text(
            'Overview',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Events',
                  '$totalEvents',
                  Icons.event,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Total Hours',
                  '$totalHours',
                  Icons.timer,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Avg Score',
                  '$avgScore/100',
                  Icons.star,
                  Colors.amber,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Sectors',
                  '${sectorCounts.length}',
                  Icons.category,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Sectors Breakdown
          if (sectorCounts.isNotEmpty) ...[
            Text(
              'Events by Sector',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: sectorCounts.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              entry.key,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${entry.value}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Verdict Breakdown
          if (verdictCounts.isNotEmpty) ...[
            Text(
              'Events by Verdict',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: verdictCounts.entries.map((entry) {
                    Color color = entry.key == 'Worth It!'
                        ? Colors.green
                        : entry.key == 'Probably Worth It'
                            ? Colors.blue
                            : entry.key == 'Maybe'
                                ? Colors.orange
                                : Colors.red;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  entry.key,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${entry.value}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // All Events List
          Text(
            'All Events',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          if (events.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'No events yet',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            )
          else
            ...events.map((event) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    event.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('${event.organizer} • ${event.duration} hours'),
                      if (event.sector != null) Text(event.sector!),
                    ],
                  ),
                  trailing: event.worthItScore != null
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${event.worthItScore}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                        )
                      : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailScreen(event: event),
                      ),
                    );
                  },
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
