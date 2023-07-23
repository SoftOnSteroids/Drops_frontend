import 'dart:convert';
// import 'dose.dart';

List<Dropper> droppersFromJson(String str) => List<Dropper>.from(json.decode(str).map((x) => Dropper.fromJson(x)));

String droppersToJson(List<Dropper> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Dropper {
    String id;
    String name;
    String? description;
    String? code;
    int? placeApply;
    int? frequency;
    DateTime? startDatetime;
    DateTime? endDay;
    DateTime? dateExpiration;
    // List<Dose>? doses;

    Dropper({
        required this.id,
        required this.name,
        this.description,
        this.code,
        this.placeApply,
        this.frequency,
        this.startDatetime,
        this.endDay,
        this.dateExpiration,
        // this.doses,
    });

    factory Dropper.fromJson(Map<String, dynamic> jStr) => Dropper(
        id: jStr["_id"],
        name: jStr["name"],
        description: jStr["description"],
        code: jStr["code"],
        placeApply: jStr["place_apply"],
        frequency: jStr["frequency"],
        startDatetime: (jStr["start_datetime"] != null) ? DateTime.parse(jStr["start_datetime"]) : null,
        endDay: (jStr["end_day"] != null) ? DateTime.parse(jStr["end_day"]) : null,
        dateExpiration: (jStr["date_expiration"] != null) ? DateTime.parse(jStr["date_expiration"]) : null,
        // doses: (jStr["doses"] != null) ? dosesFromJson(jsonEncode(jStr["doses"])) : List<Dose>.empty(),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "code": code,
        "place_apply": placeApply,
        "frequency": frequency,
        "start_datetime": startDatetime,
        "end_day": endDay,
        "date_expiration": dateExpiration,
        // "doses": doses,
    };
}

// List droppers = [
//   {
//     "id": "6417b00c36a1f48e085739f6",
//     "name": "Clorhexidina",
//     "code": "2904282",
//     "description": null,
//     "cold_chain": false,
//     "volume": 10,
//     "date_expiration": "2023-05-07",
//     "color": "white",
//     "opened": true
//   },
//   {
//     "id": "6417e646f1a687ad69c5ac7d",
//     "name": "PHMB",
//     "code": "904281",
//     "description": "Para quistes de Acanthamoeba",
//     "cold_chain": false,
//     "volume": 10,
//     "date_expiration": "2023-05-07",
//     "color": "white",
//     "opened": true
//   },
//   {
//     "id": "641c8fe95231d58846b64dc9",
//     "date_expiration": "2023-04-22",
//     "name": "Voriconazol",
//     "code": "2904280",
//     "description": "Antimicótico",
//     "cold_chain": false,
//     "volume": 5,
//     "color": "white",
//     "opened": true
//   },
//   {
//     "id": "641ca63dee673e7e8d9d6ec9",
//     "date_expiration": "2023-04-08",
//     "name": "Ciclosporina",
//     "code": "2905086",
//     "description": "Modulador inmunológico",
//     "cold_chain": false,
//     "volume": 5,
//     "color": "white",
//     "opened": true
//   },
//   {
//     "id": "641cb02c3b6bb5ddbc9be085",
//     "date_expiration": "2023-09-11",
//     "name": "Artelac - Rebalance",
//     "code": null,
//     "description": "Lágrima artificial",
//     "cold_chain": null,
//     "volume": 10,
//     "color": null,
//     "opened": true
//   },
//   {
//     "id": "64206bc9bf66f7ea177404e7",
//     "date_expiration": "2023-04-19",
//     "name": "Anfotericina",
//     "code": "2906258",
//     "description": null,
//     "cold_chain": true,
//     "volume": 10,
//     "color": "white",
//     "opened": true
//   },
//   {
//     "id": "642dcc39b6dc695736bbe2dd",
//     "date_expiration": "1024-04-01",
//     "name": "Sedesterol",
//     "code": "4018801904",
//     "description": "Corticoide - Dexametasona 21 fosfato de sodio 0.1%",
//     "cold_chain": false,
//     "volume": 5,
//     "color": "white",
//     "opened": true
//   }
// ];
