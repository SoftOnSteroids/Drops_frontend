import 'dart:collection';
import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:drops_app/models/api_constants.dart';
import 'package:drops_app/models/dropper.dart';
import 'package:drops_app/models/dose.dart';
import 'package:collection/collection.dart';
import 'package:drops_app/models/event.dart';

class ApiService {
  Future<List<Dropper>> getDroppers() async {
    try {
      final url =
          Uri.https(ApiConstants.baseUrl, ApiConstants.droppersEndpoint);
      var response = await http.get(
        url,
        headers: ApiConstants.headersJson,
      );
      List<Dropper> modelDroppers = (response.statusCode == 200)
          ? droppersFromJson(utf8.decode(response.bodyBytes))
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
      // String uri = ApiConstants.baseUrl + ApiConstants.dosesEndpoint;
      // String uriEndpoint = ApiConstants.dosesEndpoint;
      // if (start != null && end != null) {
      //   uriEndpoint +=
      //       "?start=${start.toIso8601String()}&end=${end.toIso8601String()}";
      // } else if (start != null || end != null) {
      //   if (start != null) {
      //     uriEndpoint += "?start=${start.toIso8601String()}";
      //   } else {
      //     uriEndpoint += "?end=${end!.toIso8601String()}";
      //   }
      // }
      // if (placeApply != null) {
      //   uriEndpoint += (uriEndpoint.contains("?")) ? "&" : "?";
      //   uriEndpoint += "place_apply=$placeApply";
      // }
      Map<String, String?> preQuery = <String, String?>{
        "start": start?.toIso8601String(),
        "end": end?.toIso8601String(),
        "place_apply": placeApply?.toString(),
      };
      Map<String, String> query = {};
      for (final entry in preQuery.entries) {
        if (entry.value != null) {
          query.addAll({entry.key: entry.value!});
        }
      }
      var response = await http.get(
        Uri.https(ApiConstants.baseUrl, ApiConstants.dosesEndpoint,
            (query.isNotEmpty) ? query : null),
        headers: ApiConstants.headersJson,
      );
      // print("Request: ${Uri.https(ApiConstants.baseUrl, ApiConstants.dosesEndpoint, (query.isNotEmpty) ? query : null)}");
      // print("Doses returned from server: ${utf8.decode(response.bodyBytes)}");
      List<Dose> modelDoses = (response.statusCode == 200)
          ? dosesFromJson(utf8.decode(response.bodyBytes))
          : List<Dose>.empty();
      return modelDoses;
    } catch (e, stackTrace) {
      log(e.toString());
      log(stackTrace.toString());
    }
    return List<Dose>.empty();
  }

  Future<http.Response> saveDropper(Dropper dropper) async {
    late Future<http.Response> response;
    try {
      String uri = ApiConstants.droppersEndpoint;
      response = (dropper.id.isNotEmpty)
          ? http.put(Uri.https(ApiConstants.baseUrl, uri),
              headers: ApiConstants.headersJson, body: json.encode(dropper))
          : http.post(Uri.https(ApiConstants.baseUrl, uri),
              headers: ApiConstants.headersJson, body: json.encode(dropper));
      // return Future.delayed(const Duration(seconds: 1));
    } catch (e, stackTrace) {
      log(e.toString());
      log(stackTrace.toString());
    }
    return response;
  }

  Future<http.Response> deleteDropper(Dropper dropper) async {
    String uri = ApiConstants.droppersEndpoint;
    return http.delete(Uri.https(ApiConstants.baseUrl, uri),
        headers: ApiConstants.headersJson, body: json.encode(dropper));
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

final Future<List<Event>> getAllEvents =
    ApiService().getDoses().then((dbDoses) {
  return Event.fromListDoses(dbDoses);
});

/// Clock
Stream<DateTime> getTimeStream() {
  return Stream<DateTime>.periodic(
      const Duration(seconds: 1), (_) => DateTime.now());
}
