import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/job_model.dart';
import '../services/firestore_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Job>> _events = {};
  late final ValueNotifier<List<Job>> _selectedEvents;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));

    _firestoreService.getJobs().listen((jobs) {
      final events = <DateTime, List<Job>>{};
      for (final job in jobs) {
        final date = DateTime.utc(job.dueDate.year, job.dueDate.month, job.dueDate.day);
        if (events[date] == null) {
          events[date] = [];
        }
        events[date]!.add(job);
      }
      setState(() {
        _events = events;
      });
       _selectedEvents.value = _getEventsForDay(_selectedDay!);
    });
  }

   @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Job> _getEventsForDay(DateTime day) {
    final date = DateTime.utc(day.year, day.month, day.day);
    return _events[date] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          Material(
            elevation: 2,
            child: Container(
              color: theme.cardColor,
              child: TableCalendar<Job>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: _getEventsForDay,
                onDaySelected: _onDaySelected,
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  todayDecoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(128),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                  weekendTextStyle: TextStyle(color: theme.colorScheme.error),
                ),
                headerStyle: HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                  titleTextStyle: theme.textTheme.titleLarge!,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<Job>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                if (value.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_note_outlined, size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text('No Jobs for this Day', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: value.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final job = value[index];
                    return Card(
                       margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        leading: CircleAvatar(
                          backgroundColor: job.status == 'Completed' 
                              ? Colors.green.shade100
                              : theme.colorScheme.primaryContainer,
                          child: Icon(
                            job.status == 'Completed' ? Icons.check_circle_outline : Icons.work_outline,
                             color: job.status == 'Completed' 
                              ? Colors.green
                              : theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        title: Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          'Due: ${DateFormat.yMMMd().format(job.dueDate)} - Status: ${job.status}',
                        ),
                        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                        onTap: () => context.go('/jobs/detail/${job.id}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
