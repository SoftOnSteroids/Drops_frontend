import 'dart:collection';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:doses_app/models/api_constants.dart';
import 'package:doses_app/models/dropper.dart';
import 'package:doses_app/models/dose.dart';
import 'package:collection/collection.dart';
import 'package:doses_app/models/event.dart';

class ApiService {
  Future<List<Dropper>> getDroppers() async {
    try {
      final url =
          Uri.parse(ApiConstants.baseUrl + ApiConstants.droppersEndpoint);
      var response = await http.get(url);
      List<Dropper> modelDroppers = (response.statusCode == 200)
          ? droppersFromJson(response.body)
          : List<Dropper>.empty();
      return modelDroppers;
    } catch (e, stackTrace) {
      log(e.toString());
      log(stackTrace.toString());
    }
    return List<Dropper>.empty();
  }

  Future<List<Dose>> getDoses(
      {DateTime? start, DateTime? end, int? placeApply}) async {
    try {
      String uri = ApiConstants.baseUrl + ApiConstants.dosesEndpoint;
      if (start != null && end != null) {
        uri += "?start=${start.toIso8601String()}&end=${end.toIso8601String()}";
      } else if (start != null || end != null) {
        if (start != null) {
          uri += "?start=${start.toIso8601String()}";
        } else {
          uri += "?end=${end!.toIso8601String()}";
        }
      }
      if (placeApply != null) {
        uri += (uri.contains("?")) ? "&" : "?";
        uri += "place_apply=$placeApply";
      }
      var response = await http.get(Uri.parse(uri));
      List<Dose> modelDoses = (response.statusCode == 200)
          ? dosesFromJson(response.body)
          : List<Dose>.empty();
      return modelDoses;
    } catch (e, stackTrace) {
      log(e.toString());
      log(stackTrace.toString());
    }
    return List<Dose>.empty();
  }
}

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Checks if two DateTime objects are the same day and time.
/// Returns `false` if either of them is null.
bool isSameDayTime(DateTime? a, DateTime? b) {
  if (a == null || b == null) {
    return false;
  }

  return a.year == b.year &&
      a.month == b.month &&
      a.day == b.day &&
      a.hour == b.hour &&
      a.minute == b.minute;
}

// Separate kDoses LinkedHashMap logic from getEvents() so DB query is called only once.
final Future<LinkedHashMap<DateTime, List<Dose>>> dtGroupedDoses =
    ApiService().getDoses().then((dbDoses) {
  Map<DateTime, List<Dose>> dtGroupedDoses =
      dbDoses.groupListsBy<DateTime>((dbDose) => dbDose.applicationDateTime);
  return LinkedHashMap<DateTime, List<Dose>>(
    equals: isSameDayTime,
    hashCode: getHashCode,
  )..addAll(dtGroupedDoses);
});

final Future<List<Event>> allEvents = ApiService().getDoses().then((dbDoses) {
  return Event.fromListDoses(dbDoses);
});

/// Clock
Stream<DateTime> getTimeStream() {
  return Stream<DateTime>.periodic(const Duration(seconds: 1), (_) => DateTime.now());
}