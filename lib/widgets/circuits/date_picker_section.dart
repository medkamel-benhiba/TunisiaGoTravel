import 'package:flutter/material.dart';
import 'package:tunisiagotravel/theme/color.dart';

class DateRangeCalendar extends StatefulWidget {
  final Function(DateTime?, DateTime?) onRangeSelected;

  const DateRangeCalendar({
    super.key,
    required this.onRangeSelected,
  });

  @override
  State<DateRangeCalendar> createState() => _DateRangeCalendarState();
}

class _DateRangeCalendarState extends State<DateRangeCalendar> {
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime _focusedDay = DateTime.now();
  PageController? _pageController;
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
                      _focusedDay = _currentMonth;
                    });
                  },
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  _getMonthYearText(_currentMonth),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
                      _focusedDay = _currentMonth;
                    });
                  },
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),


            // Days of week header
            Row(
              children: ['Lu', 'Ma', 'Me', 'Je', 'Ve', 'Sa', 'Di']
                  .map((day) => Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ))
                  .toList(),
            ),

            const SizedBox(height: 8),

            // Calendar grid
            _buildCalendarGrid(),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;

    // Calculate how many cells we need
    final totalCells = daysInMonth + (firstWeekday - 1);
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (rowIndex) {
        return Row(
          children: List.generate(7, (colIndex) {
            final cellIndex = rowIndex * 7 + colIndex;
            final dayNumber = cellIndex - (firstWeekday - 1) + 1;

            if (dayNumber < 1 || dayNumber > daysInMonth) {
              // Empty cell for days outside current month
              return const Expanded(child: SizedBox(height: 40));
            }

            final date = DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
            final isToday = _isSameDay(date, DateTime.now());
            final isPast = date.isBefore(DateTime.now().subtract(const Duration(days: 1)));
            final isSelected = _isDateSelected(date);
            final isInRange = _isDateInRange(date);

            return Expanded(
              child: GestureDetector(
                onTap: isPast ? null : () => _onDateTapped(date),
                child: Container(
                  height: 40,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColorstatic.primary
                        : isInRange
                        ? AppColorstatic.primary.withOpacity(0.3)
                        : isToday
                        ? Colors.blue.shade100
                        : null,
                    borderRadius: BorderRadius.circular(8),
                    border: isToday
                        ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      dayNumber.toString(),
                      style: TextStyle(
                        color: isPast
                            ? Colors.grey.shade400
                            : isSelected
                            ? Colors.white
                            : isInRange
                            ? Theme.of(context).primaryColor
                            : isToday
                            ? Theme.of(context).primaryColor
                            : Colors.black,
                        fontWeight: isSelected || isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  void _onDateTapped(DateTime date) {
    setState(() {
      if (_startDate == null || (_startDate != null && _endDate != null)) {
        // Start new selection
        _startDate = date;
        _endDate = null;
      } else if (_startDate != null && _endDate == null) {
        // Select end date
        if (date.isBefore(_startDate!)) {
          // If selected date is before start date, swap them
          _endDate = _startDate;
          _startDate = date;
        } else {
          _endDate = date;
        }
      }
    });

    // Notify parent widget
    widget.onRangeSelected(_startDate, _endDate);
  }

  bool _isDateSelected(DateTime date) {
    return (_startDate != null && _isSameDay(date, _startDate!)) ||
        (_endDate != null && _isSameDay(date, _endDate!));
  }

  bool _isDateInRange(DateTime date) {
    if (_startDate == null || _endDate == null) return false;
    return date.isAfter(_startDate!) && date.isBefore(_endDate!);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _getMonthYearText(DateTime date) {
    const months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
      'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}