import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/event_model.dart';
import '../services/ai_service.dart';
import '../services/storage_service.dart';

class LinkedInPostScreen extends StatefulWidget {
  final Event event;
  final String reflection;
  final String takeaways;
  final String? networking;
  final bool? certificateReceived;
  final String? projectOutput;

  const LinkedInPostScreen({
    Key? key,
    required this.event,
    required this.reflection,
    required this.takeaways,
    this.networking,
    this.certificateReceived,
    this.projectOutput,
  }) : super(key: key);

  @override
  State<LinkedInPostScreen> createState() => _LinkedInPostScreenState();
}

class _LinkedInPostScreenState extends State<LinkedInPostScreen> {
  bool isGenerating = true;
  final _postController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _generatePost();
  }

  Future<void> _generatePost() async {
    setState(() => isGenerating = true);

    final post = await AIService.generateLinkedInPost(
      eventName: widget.event.name,
      reflection: widget.reflection,
      takeaways: widget.takeaways,
      networking: widget.networking,
      certificateReceived: widget.certificateReceived,
      projectOutput: widget.projectOutput,
    );

    setState(() {
      _postController.text = post;
      isGenerating = false;
    });
  }

  // Combined logic for Copying and Saving
  Future<void> _copyAndSave() async {
    final postContent = _postController.text;

    // 1. Copy to clipboard
    await Clipboard.setData(ClipboardData(text: postContent));

    // 2. Save the post to the event model
    final updatedEvent = widget.event.copyWith(
      linkedInPost: postContent,
    );
    await StorageService.updateEvent(updatedEvent);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post copied and saved!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _saveAndFinish() async {
    final updatedEvent = widget.event.copyWith(
      linkedInPost: _postController.text,
    );

    await StorageService.updateEvent(updatedEvent);

    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isGenerating) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Generating Post'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              const Text(
                'AI is crafting your LinkedIn post...',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Making it professional and engaging',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('LinkedIn Post'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _generatePost,
            tooltip: 'Regenerate',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'AI-Generated LinkedIn Post',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Edit the post below before copying',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),

            // Editable Post Card
            Expanded(
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue[700],
                            child:
                                const Icon(Icons.person, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Your Name',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Student | Technology Enthusiast',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      Expanded(
                        child: TextField(
                          controller: _postController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Edit your post...',
                          ),
                          maxLines: null,
                          style: const TextStyle(height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Updated Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _copyAndSave, // Using the new unified function
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy & Save'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveAndFinish,
                    icon: const Icon(Icons.check),
                    label: const Text('Finish'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Tips Card
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.tips_and_updates,
                      color: Colors.blue[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Tip: Add relevant hashtags and tag people you mentioned!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }
}
