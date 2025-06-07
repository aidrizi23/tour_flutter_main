import 'package:flutter/material.dart';
import '../../../models/booking_models.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';

class BookingBottomSheet extends StatefulWidget {
  final DateTime? selectedDate;
  final int people;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<int> onPeopleChanged;
  final VoidCallback onCheckAvailability;
  final AvailabilityResponse? availability;
  final bool checkingAvailability;
  final bool booking;
  final VoidCallback onBook;
  const BookingBottomSheet({
    super.key,
    required this.selectedDate,
    required this.people,
    required this.onDateChanged,
    required this.onPeopleChanged,
    required this.onCheckAvailability,
    required this.availability,
    required this.checkingAvailability,
    required this.booking,
    required this.onBook,
  });

  @override
  State<BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<BookingBottomSheet> {
  final TextEditingController _dateController = TextEditingController();

  @override
  void didUpdateWidget(covariant BookingBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    _dateController.text =
        widget.selectedDate == null
            ? ''
            : MaterialLocalizations.of(
              context,
            ).formatMediumDate(widget.selectedDate!);
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date != null) widget.onDateChanged(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: MediaQuery.of(context).viewInsets.add(const EdgeInsets.all(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: _pickDate,
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: widget.people,
                  onChanged:
                      (v) => v != null ? widget.onPeopleChanged(v) : null,
                  decoration: const InputDecoration(labelText: 'People'),
                  items:
                      List.generate(10, (i) => i + 1)
                          .map(
                            (e) =>
                                DropdownMenuItem(value: e, child: Text('$e')),
                          )
                          .toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomButton(
            onPressed:
                widget.checkingAvailability ? null : widget.onCheckAvailability,
            isLoading: widget.checkingAvailability,
            text: 'Check Availability',
            minimumSize: const Size(double.infinity, 48),
          ),
          if (widget.availability != null) ...[
            const SizedBox(height: 12),
            Text(
              widget.availability!.statusText,
              style: TextStyle(color: widget.availability!.statusColor),
            ),
          ],
          const SizedBox(height: 12),
          CustomButton(
            onPressed: widget.booking ? null : widget.onBook,
            isLoading: widget.booking,
            text: 'Book Now',
            minimumSize: const Size(double.infinity, 48),
          ),
        ],
      ),
    );
  }
}
