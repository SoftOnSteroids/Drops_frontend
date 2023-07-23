import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../models/event.dart';
import '../widgets/calendar_utils.dart';
import '../widgets/indicator_widget.dart';
import './hour_timetable.dart';
import '../models/api_service.dart';

class DosesDayCalendarPage extends StatefulWidget {
  const DosesDayCalendarPage({
    super.key,
  });

  @override
  State<DosesDayCalendarPage> createState() => _DosesDayCalendarPageState();
}

class _DosesDayCalendarPageState extends State<DosesDayCalendarPage> {
  late ValueNotifier<List<Event>> _allEvents;
  late ValueNotifier<List<Event>> _dayEvents = ValueNotifier([]);
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    allEvents.then((value) {
      _allEvents = ValueNotifier(value);
      _selectedDay = _focusedDay;
      _dayEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
      Future.delayed(const Duration(seconds: 1))
          .then((value) => setState(() {}));
    });
  }

  @override
  void dispose() {
    _dayEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime dtime) {
    List<Event> dayEvents = [];
    for (var kEvent in _allEvents.value) {
      if (isSameDay(kEvent.applicationDateTime, dtime)) {
        dayEvents.add(kEvent);
      }
    }
    return dayEvents;
  }

  @override
  Widget build(BuildContext context) {
    // var mainAppState = Provider.of<MainAppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doses reminder'),
      ),
      body: (_dayEvents.value.isEmpty)
          ? Center(
              child: getIndicatorWidget(defaultTargetPlatform),
            )
          : Center(
              child: Column(
                children: [
                  TableCalendar<Event>(
                    calendarFormat: _calendarFormat,
                    locale: "en_US",
                    firstDay: kFirstDay,
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                    ),
                    lastDay: kLastDay,
                    focusedDay: _focusedDay,
                    eventLoader: _getEventsForDay,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: _onDaySelected,
                    onFormatChanged: (format) {
                      if (_calendarFormat != format) {
                        // Call `setState()` when updating calendar format
                        setState(() {
                          _calendarFormat = format;
                        });
                      }
                    },
                    onPageChanged: (focusedDay) {
                      // No need to call `setState()` here
                      _focusedDay = focusedDay;
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StreamBuilder<DateTime>(
                        stream: getTimeStream(),
                        builder: (context, snapshot) {
                          return (snapshot.hasData)
                              ? Text(DateFormat("HH:mm").format(snapshot.data!))
                              : const Text("Loading...");
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.today),
                        onPressed: () {
                          _onDaySelected(DateTime.now(), DateTime.now());
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Expanded(
                    child: ValueListenableBuilder<List<Event>>(
                      valueListenable: _dayEvents,
                      builder: (context, events, _) {
                        return ListView.builder(
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            // final item = droppers[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 4.0,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: ListTile(
                                onTap: () {
                                  // print('${value[index]}');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DosesHourTimetablePage(
                                        datetime:
                                            events[index].applicationDateTime,
                                      ),
                                    ),
                                  );
                                },
                                title: Text(
                                    '${DateFormat(DateFormat.HOUR24_MINUTE).format(events[index].applicationDateTime)}: ${events[index].doses.length} Dosis'),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _onDaySelected(selectedDay, focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      // Call `setState()` when updating the selected day
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _dayEvents.value = _getEventsForDay(selectedDay);
      });
    }
  }
}

class MainAppState extends ChangeNotifier {
  // var dateSelected = CalendarDatePicker();
}
