import 'dart:async';

import 'package:flutter/material.dart';

class KitchenTimer extends StatefulWidget {
  final DateTime startedAt;

  const KitchenTimer({
    super.key,
    required this.startedAt,
  });

  @override
  State<KitchenTimer> createState() => _KitchenTimerState();
}

class _KitchenTimerState extends State<KitchenTimer> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted) return;
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = DateTime.now().difference(widget.startedAt);
    final duration = elapsed.isNegative ? Duration.zero : elapsed;

    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    Color color = Colors.green;

    if (minutes >= 20) {
      color = Colors.red;
    } else if (minutes >= 10) {
      color = Colors.orange;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.timer,
          color: color,
          size: 18,
        ),
        const SizedBox(width: 4),
        Text(
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
