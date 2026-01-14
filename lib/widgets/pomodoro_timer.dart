import 'dart:async';
import 'package:flutter/material.dart';

class PomodoroTimer extends StatefulWidget {
  const PomodoroTimer({Key? key}) : super(key: key);

  @override
  State<PomodoroTimer> createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer> {
  static const int workDuration = 25 * 60; // 25 minutes in seconds
  static const int breakDuration = 5 * 60; // 5 minutes in seconds

  int remainingSeconds = workDuration;
  bool isRunning = false;
  bool isWorkMode = true;
  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    setState(() {
      if (isRunning) {
        timer?.cancel();
        isRunning = false;
      } else {
        isRunning = true;
        timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            if (remainingSeconds > 0) {
              remainingSeconds--;
            } else {
              _completeSession();
            }
          });
        });
      }
    });
  }

  void _completeSession() {
    timer?.cancel();
    setState(() {
      isRunning = false;
      isWorkMode = !isWorkMode;
      remainingSeconds = isWorkMode ? workDuration : breakDuration;
    });

    // Show completion dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            isWorkMode ? '🎉 Break Complete!' : '✅ Work Session Complete!'),
        content: Text(
          isWorkMode
              ? 'Time to get back to work!'
              : 'Great job! Take a well-deserved break.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _resetTimer() {
    setState(() {
      timer?.cancel();
      isRunning = false;
      isWorkMode = true;
      remainingSeconds = workDuration;
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = isWorkMode
        ? (workDuration - remainingSeconds) / workDuration
        : (breakDuration - remainingSeconds) / breakDuration;

    return Card(
      color: isWorkMode ? Colors.blue[50] : Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isWorkMode ? Icons.work : Icons.coffee,
                      color: isWorkMode ? Colors.blue[700] : Colors.green[700],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isWorkMode ? 'Focus Time' : 'Break Time',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color:
                            isWorkMode ? Colors.blue[900] : Colors.green[900],
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _resetTimer,
                  tooltip: 'Reset',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Timer Display
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 8,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isWorkMode ? Colors.blue : Colors.green,
                          ),
                        ),
                      ),
                      Text(
                        _formatTime(remainingSeconds),
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          color:
                              isWorkMode ? Colors.blue[900] : Colors.green[900],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Control Button
                  ElevatedButton.icon(
                    onPressed: _toggleTimer,
                    icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
                    label: Text(isRunning ? 'Pause' : 'Start'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isWorkMode ? Colors.blue : Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Instructions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.tips_and_updates,
                    size: 16,
                    color: Colors.grey[700],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isWorkMode
                          ? 'Focus for 25 minutes without distractions'
                          : 'Take a 5-minute break to recharge',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
