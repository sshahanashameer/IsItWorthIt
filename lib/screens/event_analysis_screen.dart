import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/ai_service.dart';
import '../services/storage_service.dart';
import '../services/calendar_service.dart'; // Added as requested

class EventAnalysisScreen extends StatefulWidget {
  final String eventName;
  final String description;
  final String organizer;
  final String organizerType;
  final int duration;
  final DateTime date;
  final TimeOfDay time;

  const EventAnalysisScreen({
    Key? key,
    required this.eventName,
    required this.description,
    required this.organizer,
    required this.organizerType,
    required this.duration,
    required this.date,
    required this.time,
  }) : super(key: key);

  @override
  State<EventAnalysisScreen> createState() => _EventAnalysisScreenState();
}

class _EventAnalysisScreenState extends State<EventAnalysisScreen> {
  bool isAnalyzing = true;
  Map<String, dynamic>? analysisData;

  @override
  void initState() {
    super.initState();
    _analyzeEvent();
  }

  Future<void> _analyzeEvent() async {
    setState(() => isAnalyzing = true);

    final analysis = await AIService.analyzeEvent(
      eventName: widget.eventName,
      description: widget.description,
      organizer: widget.organizer,
      organizerType: widget.organizerType,
      duration: widget.duration,
    );

    setState(() {
      analysisData = analysis;
      isAnalyzing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isAnalyzing) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Analyzing Event'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              const Text(
                'AI is analyzing your event...',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'This may take a few seconds',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    // Extraction of analysis data for UI
    final verdict = analysisData!['verdict'];
    final worthItScore = analysisData!['worthItScore'];
    final sector = analysisData!['sector'];
    final skills = List<String>.from(analysisData!['skills']);
    final portfolioImpact = analysisData!['portfolioImpact'];
    final internshipAlignment = analysisData!['internshipAlignment'];
    final odHourAnalysis = analysisData!['odHourAnalysis'];
    final missingInfo = List<Map<String, String>>.from(
        (analysisData!['missingInfo'] as List)
            .map((e) => Map<String, String>.from(e)));
    final aiSummary = analysisData!['aiSummary'];

    Color verdictColor = verdict == 'Worth It!'
        ? Colors.green
        : verdict == 'Probably Worth It'
            ? Colors.blue
            : verdict == 'Maybe'
                ? Colors.orange
                : Colors.red;

    IconData verdictIcon = verdict == 'Worth It!'
        ? Icons.check_circle
        : verdict == 'Probably Worth It'
            ? Icons.thumb_up
            : verdict == 'Maybe'
                ? Icons.help_outline
                : Icons.cancel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Analysis'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Verdict Card
          Card(
            color: verdictColor.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(verdictIcon, size: 64, color: verdictColor),
                  const SizedBox(height: 16),
                  Text(
                    verdict,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: verdictColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$worthItScore',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: verdictColor,
                        ),
                      ),
                      Text(
                        '/100',
                        style: TextStyle(
                          fontSize: 24,
                          color: verdictColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Worth-It Score',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // AI Summary
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        'AI Summary',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    aiSummary,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          _buildAnalysisSection(
            context,
            'Portfolio Impact',
            Icons.business_center,
            [
              _buildInfoRow('Impact Level', portfolioImpact['level']),
              _buildInfoRow(
                  'Resume Placement', portfolioImpact['resumePlacement']),
              _buildInfoRow(
                  'Signal Strength', portfolioImpact['signalStrength']),
              _buildInfoRow('Longevity', portfolioImpact['longevity']),
            ],
          ),

          _buildAnalysisSection(
            context,
            'Skills & Learning',
            Icons.school,
            [
              _buildInfoRow('Sector', sector),
              const SizedBox(height: 12),
              const Text('Skills you\'ll gain:',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: skills
                    .map((skill) => Chip(
                          label: Text(skill),
                          backgroundColor: Colors.blue[100],
                        ))
                    .toList(),
              ),
            ],
          ),

          _buildAnalysisSection(
            context,
            'Internship Alignment',
            Icons.work,
            [
              _buildInfoRow('Relevance Score',
                  '${internshipAlignment['relevanceScore']}/10'),
              _buildInfoRow('Target Role', internshipAlignment['targetRole']),
              _buildInfoRow(
                  'Network Potential', internshipAlignment['networkPotential']),
            ],
          ),

          _buildAnalysisSection(
            context,
            'OD Hour Analysis',
            Icons.timer,
            [
              _buildInfoRow(
                  'Hours Required', '${odHourAnalysis['hoursRequired']}'),
              _buildInfoRow(
                  'Remaining After', '${odHourAnalysis['remainingAfter']}'),
              _buildInfoRow(
                  'Cost-Benefit Ratio', odHourAnalysis['costBenefitRatio']),
            ],
          ),

          if (missingInfo.isNotEmpty)
            Card(
              color: Colors.orange[50],
              child: ExpansionTile(
                leading: const Icon(Icons.help_outline, color: Colors.orange),
                title: const Text(
                  'Missing Information',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${missingInfo.length} questions to ask'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Questions to ask organizer:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...missingInfo
                            .map((info) => _buildQuestion(info['question']!)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),

          // Updated Action Buttons Section
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // Show loading
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );

                    // Map the current date and time
                    final startDateTime = DateTime(
                      widget.date.year,
                      widget.date.month,
                      widget.date.day,
                      widget.time.hour,
                      widget.time.minute,
                    );

                    // Save event locally
                    final event = Event(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: widget.eventName,
                      description: widget.description,
                      organizer: widget.organizer,
                      organizerType: widget.organizerType,
                      duration: widget.duration,
                      date: widget.date,
                      time: startDateTime,
                      sector: analysisData!['sector'],
                      verdict: analysisData!['verdict'],
                      worthItScore: analysisData!['worthItScore'],
                      analysisData: analysisData,
                    );

                    await StorageService.addEvent(event);

                    // Add to Google Calendar
                    final endDateTime = startDateTime.add(
                      Duration(hours: widget.duration),
                    );

                    final calendarAdded =
                        await CalendarService.addToGoogleCalendar(
                      eventName: widget.eventName,
                      description: widget.description,
                      location: widget.organizer,
                      startDateTime: startDateTime,
                      endDateTime: endDateTime,
                    );

                    if (mounted) {
                      Navigator.pop(context); // Close loading dialog

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            calendarAdded
                                ? 'Event saved! Opening Google Calendar...'
                                : 'Event saved! Add to calendar manually',
                          ),
                          backgroundColor: Colors.green,
                          action: !calendarAdded
                              ? SnackBarAction(
                                  label: 'Download .ics',
                                  textColor: Colors.white,
                                  onPressed: () async {
                                    await CalendarService.downloadICalFile(
                                      eventName: widget.eventName,
                                      description: widget.description,
                                      location: widget.organizer,
                                      startDateTime: startDateTime,
                                      endDateTime: endDateTime,
                                    );
                                  },
                                )
                              : null,
                        ),
                      );

                      // Go back to dashboard
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Register + Add to Calendar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('Skip Event'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Card(
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[700]),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(String question) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              question,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
