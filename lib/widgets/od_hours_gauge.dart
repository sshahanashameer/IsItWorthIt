import 'package:flutter/material.dart';

class ODHoursGauge extends StatelessWidget {
  final int totalHours;
  final int usedHours;

  const ODHoursGauge({
    Key? key,
    required this.totalHours,
    required this.usedHours,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final remaining = totalHours - usedHours;
    final percentage = remaining / totalHours;

    Color gaugeColor;
    String statusText;

    if (remaining > totalHours * 0.5) {
      gaugeColor = Colors.green;
      statusText = 'Plenty of hours left';
    } else if (remaining > totalHours * 0.25) {
      gaugeColor = Colors.orange;
      statusText = 'Use wisely';
    } else if (remaining > 0) {
      gaugeColor = Colors.red;
      statusText = 'Running low!';
    } else {
      gaugeColor = Colors.grey;
      statusText = 'No hours remaining';
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'OD Hours Tracker',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Circular Gauge
            SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 16,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.transparent,
                      ),
                    ),
                  ),
                  // Progress circle
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: CircularProgressIndicator(
                      value: percentage.clamp(0.0, 1.0),
                      strokeWidth: 16,
                      valueColor: AlwaysStoppedAnimation<Color>(gaugeColor),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  // Center text
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${remaining.clamp(0, totalHours)}',
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: gaugeColor,
                        ),
                      ),
                      Text(
                        'hours left',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Status
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: gaugeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: gaugeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDetail('Total', '$totalHours h', Icons.schedule),
                _buildDetail('Used', '$usedHours h', Icons.trending_up),
                _buildDetail('Free', '${remaining.clamp(0, totalHours)} h',
                    Icons.check_circle),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetail(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
