import 'package:flutter/material.dart';
import '../../../widgets/custom_button.dart';

class BookingPanel extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onBook;
  const BookingPanel({super.key, required this.onClose, required this.onBook});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Book Tour',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              CustomButton(
                onPressed: onBook,
                text: 'Proceed to booking',
                icon: Icons.check_circle,
              ),
              const SizedBox(height: 12),
              TextButton(onPressed: onClose, child: const Text('Cancel')),
            ],
          ),
        ),
      ),
    );
  }
}
