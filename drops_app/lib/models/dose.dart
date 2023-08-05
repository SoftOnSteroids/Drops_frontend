// To parse this JSON data, do
//
//     final dose = dosesFromJson(jsonString);

import 'dart:convert';

List<Dose> dosesFromJson(String jDoses) => List<Dose>.from(json.decode(jDoses).map((jDose) => Dose.fromJson(jDose)));

String dosesToJson(List<Dose> doses) => json.encode(List<dynamic>.from(doses.map((dose) => dose.toJson())));

class Dose {
    String dropperId;
    DateTime applicationDateTime;

    Dose({
        required this.dropperId,
        required this.applicationDateTime,
    });

    factory Dose.fromJson(Map<String, dynamic> json) => Dose(
        dropperId: json["dropper_id"],
        applicationDateTime: DateTime.parse(json["application_datetime"]),
    );

    Map<String, dynamic> toJson() => {
        "dropper_id": dropperId,
        "application_time": applicationDateTime,
    };
}
