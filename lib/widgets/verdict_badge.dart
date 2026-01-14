import 'package:flutter/material.dart';

class VerdictBadge extends StatelessWidget {
  final String verdict;

  const VerdictBadge({
    Key? key,
    required this.verdict,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (verdict) {
      case 'Worth It!':
        backgroundColor = Colors.green;
        textColor = Colors.white;
        icon = Icons.check_circle;
        break;
      case 'Probably Worth It':
        backgroundColor = Colors.blue;
        textColor = Colors.white;
        icon = Icons.thumb_up;
        break;
      case 'Maybe':
        backgroundColor = Colors.orange;
        textColor = Colors.white;
        icon = Icons.help_outline;
        break;
      case 'Skip':
        backgroundColor = Colors.red;
        textColor = Colors.white;
        icon = Icons.cancel;
        break;
      default:
        backgroundColor = Colors.grey;
        textColor = Colors.white;
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            verdict,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
