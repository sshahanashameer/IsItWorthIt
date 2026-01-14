import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/storage_service.dart';
import 'linkedin_post_screen.dart';

class ReflectionScreen extends StatefulWidget {
  final Event event;

  const ReflectionScreen({Key? key, required this.event}) : super(key: key);

  @override
  State<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends State<ReflectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _whatHappenedController = TextEditingController();
  final _takeawaysController = TextEditingController();
  final _networkingController = TextEditingController();
  bool _certificateReceived = false;
  final _projectController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Reflection'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              'How was: ${widget.event.name}?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _whatHappenedController,
              decoration: const InputDecoration(
                labelText: 'What happened at the event?',
                border: OutlineInputBorder(),
                hintText: 'Describe your experience...',
                prefixIcon: Icon(Icons.event),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please describe what happened';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _takeawaysController,
              decoration: const InputDecoration(
                labelText: 'Key takeaways',
                border: OutlineInputBorder(),
                hintText: 'What did you learn? (one per line)',
                prefixIcon: Icon(Icons.lightbulb),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please list your takeaways';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _networkingController,
              decoration: const InputDecoration(
                labelText: 'People you networked with',
                border: OutlineInputBorder(),
                hintText: 'Names, roles, companies...',
                prefixIcon: Icon(Icons.people),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Card(
              child: SwitchListTile(
                title: const Text('Did you receive a certificate?'),
                subtitle: const Text('This helps track achievements'),
                value: _certificateReceived,
                onChanged: (value) {
                  setState(() {
                    _certificateReceived = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _projectController,
              decoration: const InputDecoration(
                labelText: 'Project/output created',
                border: OutlineInputBorder(),
                hintText: 'Describe what you built...',
                prefixIcon: Icon(Icons.construction),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // Save reflection data
                  final updatedEvent = widget.event.copyWith(
                    reflection: _whatHappenedController.text,
                    takeaways: _takeawaysController.text,
                    networking: _networkingController.text.isEmpty
                        ? null
                        : _networkingController.text,
                    certificateReceived: _certificateReceived,
                    projectOutput: _projectController.text.isEmpty
                        ? null
                        : _projectController.text,
                  );

                  await StorageService.updateEvent(updatedEvent);

                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LinkedInPostScreen(
                          event: updatedEvent,
                          reflection: _whatHappenedController.text,
                          takeaways: _takeawaysController.text,
                          networking: _networkingController.text.isEmpty
                              ? null
                              : _networkingController.text,
                          certificateReceived: _certificateReceived,
                          projectOutput: _projectController.text.isEmpty
                              ? null
                              : _projectController.text,
                        ),
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate LinkedIn Post'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final updatedEvent = widget.event.copyWith(
                    reflection: _whatHappenedController.text,
                    takeaways: _takeawaysController.text,
                    networking: _networkingController.text.isEmpty
                        ? null
                        : _networkingController.text,
                    certificateReceived: _certificateReceived,
                    projectOutput: _projectController.text.isEmpty
                        ? null
                        : _projectController.text,
                  );

                  await StorageService.updateEvent(updatedEvent);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reflection saved!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context);
                  }
                }
              },
              icon: const Icon(Icons.save),
              label: const Text('Save Without Post'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _whatHappenedController.dispose();
    _takeawaysController.dispose();
    _networkingController.dispose();
    _projectController.dispose();
    super.dispose();
  }
}
