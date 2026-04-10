import 'package:flutter/material.dart';

class PositiveFrictionDialog extends StatefulWidget {
  final String title;
  final String message;
  final String goalReminder;
  final VoidCallback onContinue;
  final VoidCallback onCancel;

  const PositiveFrictionDialog({
    super.key,
    required this.title,
    required this.message,
    required this.goalReminder,
    required this.onContinue,
    required this.onCancel,
  });

  @override
  State<PositiveFrictionDialog> createState() => _PositiveFrictionDialogState();
}

class _PositiveFrictionDialogState extends State<PositiveFrictionDialog> {
  bool _canContinue = false;
  int _counter = 5;

  @override
  void initState() {
    super.initState();
    _startDelay();
  }

  void _startDelay() async {
    for (int i = 5; i > 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _counter = i - 1;
        });
      }
    }
    if (mounted) {
      setState(() {
        _canContinue = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange),
          const SizedBox(width: 8),
          Text(widget.title),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.message, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(child: Text(widget.goalReminder)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (!_canContinue)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Pause & Reflect • $_counter', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                const CircularProgressIndicator(strokeWidth: 2),
              ],
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: const Text('Maybe Later'),
        ),
        ElevatedButton(
          onPressed: _canContinue ? widget.onContinue : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _canContinue ? Colors.red : Colors.grey,
          ),
          child: const Text('Continue Anyway'),
        ),
      ],
    );
  }
}