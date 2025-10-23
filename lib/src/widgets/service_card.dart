import 'package:flutter/material.dart';

class ServiceCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool selected;

  const ServiceCard({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected
              ? const Color.fromRGBO(11, 87, 208, 0.08)
              : const Color.fromRGBO(33, 150, 243, 0.06),
          borderRadius: BorderRadius.circular(12),
          border: selected
              ? Border.all(color: const Color(0xFF0B57D0), width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  const BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.04),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, size: 22, color: Colors.blue),
            ),
            const SizedBox(height: 8),
            Flexible(
              fit: FlexFit.loose,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
