import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmptyListIndicator extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyListIndicator({
    super.key,
    required this.message,
    this.icon = Icons.inventory_2_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: Colors.green.shade300),
            ),
            const SizedBox(height: 24.0),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
