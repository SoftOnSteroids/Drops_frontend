import 'dart:collection';

import 'package:doses_app/models/dose.dart';

import 'api_service.dart';

import 'package:collection/collection.dart';

class Event {
  DateTime applicationDateTime;
  List<Dose> doses;

  Event({
    required this.applicationDateTime,
    required this.doses,
  });

  factory Event.fromMap(MapEntry<DateTime, List<Dose>> mapEvent) =>
      Event(applicationDateTime: mapEvent.key, doses: mapEvent.value);

  static List<Event> fromLHMap(LinkedHashMap<DateTime, List<Dose>> dtGroupedDoses) {
    List<Event> events = [];
    for (MapEntry<DateTime, List<Dose>> groupedDoses
        in dtGroupedDoses.entries) {
      events.add(Event.fromMap(groupedDoses));
    }
    return events;
  }

  static List<Event> fromListDoses(List<Dose> doses) {
      Map<DateTime, List<Dose>> dtGroupedDoses = doses
          .groupListsBy<DateTime>((dbDose) => dbDose.applicationDateTime);

      return fromLHMap(LinkedHashMap<DateTime, List<Dose>>(
        equals: isSameDayTime,
        hashCode: getHashCode,
      )..addAll(dtGroupedDoses));
  }
}
