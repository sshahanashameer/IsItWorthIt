import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/event_model.dart';
import '../services/storage_service.dart';

class LinkedInPostsListScreen extends StatefulWidget {
  const LinkedInPostsListScreen({Key? key}) : super(key: key);

  @override
  State<LinkedInPostsListScreen> createState() =>
      _LinkedInPostsListScreenState();
}

class _LinkedInPostsListScreenState extends State<LinkedInPostsListScreen> {
  List<Event> eventsWithPosts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPostsHistory();
  }

  Future<void> _loadPostsHistory() async {
    final allEvents = await StorageService.loadEvents();
    setState(() {
      eventsWithPosts = allEvents
          .where((e) => e.linkedInPost != null && e.linkedInPost!.isNotEmpty)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date)); // Most recent first
      isLoading = false;
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LinkedIn Posts History'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : eventsWithPosts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.post_add,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No LinkedIn posts yet',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Complete event reflections to generate posts',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: eventsWithPosts.length,
                  itemBuilder: (context, index) {
                    final event = eventsWithPosts[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            event.name[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          event.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${event.date.day}/${event.date.month}/${event.date.year}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Post Content
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    event.linkedInPost!,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Action Buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _copyToClipboard(
                                            event.linkedInPost!),
                                        icon: const Icon(Icons.copy, size: 18),
                                        label: const Text('Copy Post'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          // Could open LinkedIn app/web here
                                          _copyToClipboard(event.linkedInPost!);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Post copied! Now paste it on LinkedIn'),
                                            ),
                                          );
                                        },
                                        icon:
                                            const Icon(Icons.launch, size: 18),
                                        label: const Text('Share'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
