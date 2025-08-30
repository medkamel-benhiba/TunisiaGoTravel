import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tunisiagotravel/theme/color.dart';

class DateRangeCalendar extends StatefulWidget {
  final void Function(DateTime start, DateTime end) onRangeSelected;

  const DateRangeCalendar({super.key, required this.onRangeSelected});

  @override
  State<DateRangeCalendar> createState() => _DateRangeCalendarState();
}

class _DateRangeCalendarState extends State<DateRangeCalendar> {
  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime(2030),
              focusedDay: DateTime.now(),
              rowHeight: 40,
              selectedDayPredicate: (day) {
                if (startDate != null && endDate != null) {
                  return day.isAtSameMomentAs(startDate!) ||
                      day.isAtSameMomentAs(endDate!) ||
                      (day.isAfter(startDate!) && day.isBefore(endDate!));
                } else if (startDate != null) {
                  return day.isAtSameMomentAs(startDate!);
                }
                return false;
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  if (startDate == null || (startDate != null && endDate != null)) {
                    startDate = selectedDay;
                    endDate = null;
                  } else if (startDate != null && endDate == null) {
                    if (selectedDay.isBefore(startDate!)) {
                      endDate = startDate;
                      startDate = selectedDay;
                    } else {
                      endDate = selectedDay;
                    }
                    widget.onRangeSelected(startDate!, endDate!);
                  }
                });
              },
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarBuilders: CalendarBuilders(
                rangeHighlightBuilder: (context, day, isWithinRange) {
                  if (isWithinRange) {
                    return Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(child: Text('${day.day}')),
                    );
                  }
                  return null;
                },
                selectedBuilder: (context, day, focusedDay) {
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColorstatic.primary.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Text(
              startDate == null
                  ? "Choisissez une date de début"
                  : endDate == null
                  ? "Date de début : ${startDate!.toLocal().toString().split(' ')[0]}"
                  : "Période : ${startDate!.toLocal().toString().split(' ')[0]} → ${endDate!.toLocal().toString().split(' ')[0]}",
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
