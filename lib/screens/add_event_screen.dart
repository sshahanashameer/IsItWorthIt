import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'event_analysis_screen.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({Key? key}) : super(key: key);

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _organizerController = TextEditingController();
  final _durationController = TextEditingController();

  String _organizerType = 'College Club';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Event'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Event Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.event),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter event name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Event Description / Flyer Text',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                hintText: 'Paste the event flyer text or description here...',
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _organizerController,
              decoration: const InputDecoration(
                labelText: 'Organizer Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter organizer name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _organizerType,
              decoration: const InputDecoration(
                labelText: 'Organizer Type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: const [
                DropdownMenuItem(
                    value: 'College Club', child: Text('College Club')),
                DropdownMenuItem(value: 'Company', child: Text('Company')),
                DropdownMenuItem(
                    value: 'External', child: Text('External Organization')),
              ],
              onChanged: (value) {
                setState(() {
                  _organizerType = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Duration (hours)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.timer),
                suffixText: 'hours',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter duration';
                }
                final num = int.tryParse(value);
                if (num == null || num <= 0) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Date Picker
            Card(
              child: ListTile(
                title: const Text('Event Date'),
                subtitle: Text(
                  DateFormat('MMMM d, y').format(_selectedDate),
                ),
                leading: const Icon(Icons.calendar_today),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 8),

            // Time Picker
            Card(
              child: ListTile(
                title: const Text('Event Time'),
                subtitle: Text(_selectedTime.format(context)),
                leading: const Icon(Icons.access_time),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                  );
                  if (time != null) {
                    setState(() {
                      _selectedTime = time;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventAnalysisScreen(
                        eventName: _nameController.text,
                        description: _descriptionController.text,
                        organizer: _organizerController.text,
                        organizerType: _organizerType,
                        duration: int.parse(_durationController.text),
                        date: _selectedDate,
                        time: _selectedTime,
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome),
                  SizedBox(width: 8),
                  Text(
                    'Analyze Event with AI',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _organizerController.dispose();
    _durationController.dispose();
    super.dispose();
  }
}
