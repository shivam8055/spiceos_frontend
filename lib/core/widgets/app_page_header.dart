import 'package:flutter/material.dart';

class AppPageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? action;

  const AppPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),

        ?action,
      ],
    );
  }
}