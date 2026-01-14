import 'package:flutter/material.dart';

class SectorChip extends StatelessWidget {
  final String sector;

  const SectorChip({
    Key? key,
    required this.sector,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        sector,
        style: TextStyle(
          color: Colors.blue[900],
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
