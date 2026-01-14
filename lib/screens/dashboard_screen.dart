import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/storage_service.dart';
import '../widgets/od_hours_gauge.dart';
import '../widgets/event_card.dart';
import '../widgets/pomodoro_timer.dart';
import 'add_event_screen.dart';
import 'statistics_screen.dart';
import 'event_detail_screen.dart';
import 'linkedin_posts_list_screen.dart'; // Added as requested

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Event> events = [];
  int totalODHours = 40;
  int usedODHours = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    final loadedEvents = await StorageService.loadEvents();
    final total = await StorageService.getTotalODHours();
    final used = await StorageService.getUsedODHours();

    setState(() {
      events = loadedEvents;
      totalODHours = total;
      usedODHours = used;
      isLoading = false;
    });
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final sectorsCount = events
        .where((e) => e.sector != null)
        .map((e) => e.sector)
        .toSet()
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ODWise'),
        actions: [
          // New LinkedIn Posts Button
          IconButton(
            icon: const Icon(Icons.article),
            tooltip: 'LinkedIn Posts',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LinkedInPostsListScreen(),
                ),
              );
              // Refreshing in case posts were updated or linked
              _refreshData();
            },
          ),
          // Statistics Button
          IconButton(
            icon: const Icon(Icons.analytics),
            tooltip: 'Analytics',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StatisticsScreen(),
                ),
              );
              _refreshData();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // OD Hours Gauge
                    ODHoursGauge(
                      totalHours: totalODHours,
                      usedHours: usedODHours,
                    ),
                    const SizedBox(height: 24),

                    // Quick Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard(
                            'Events', '${events.length}', Icons.event),
                        _buildStatCard(
                            'Sectors', '$sectorsCount', Icons.category),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Pomodoro Timer
                    const PomodoroTimer(),
                    const SizedBox(height: 24),

                    // Recent Events Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Events',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (events.isNotEmpty)
                          TextButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const StatisticsScreen(),
                                ),
                              );
                              _refreshData();
                            },
                            child: const Text('View All'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Event List Logic
                    if (events.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.event_available,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No events yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add your first event to get started!',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...events.take(5).map((event) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: EventCard(
                              event: event,
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EventDetailScreen(event: event),
                                  ),
                                );
                                _refreshData();
                              },
                            ),
                          )),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEventScreen(),
            ),
          );
          _refreshData();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Event'),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(label),
          ],
        ),
      ),
    );
  }
}
