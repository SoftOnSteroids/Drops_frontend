import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:drops_app/models/dropper.dart';
import 'package:drops_app/models/dose.dart';
import 'package:drops_app/models/api_service.dart';
import 'package:intl/intl.dart';

import '../widgets/indicator_widget.dart';

class HourTimetablePage extends StatefulWidget {
  final DateTime datetime;
  const HourTimetablePage({
    super.key,
    required this.datetime,
  });

  @override
  State<HourTimetablePage> createState() => _HourTimetablePageState();
}

class _HourTimetablePageState extends State<HourTimetablePage> {
  late List<Dropper>? _droppersModel = [];
  late List<Dose>? _leftDosesModel = [];
  late List<Dose>? _rightDosesModel = [];

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    _droppersModel = await ApiService().getDroppers();
    _leftDosesModel =
        await ApiService().getDoses(placeApply: 1, start: widget.datetime, end: widget.datetime);
    _rightDosesModel =
        await ApiService().getDoses(placeApply: 2, start: widget.datetime, end: widget.datetime);
    // Future.delayed(const Duration(seconds: 1)).then((value) => setState(() {}));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              "Doses ${DateFormat("yyyy-MM-dd HH:mm").format(widget.datetime)}")),
      body: (_droppersModel == null || _droppersModel!.isEmpty)
          ? Center(
              child: getIndicatorWidget(defaultTargetPlatform),
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Center(child: Text("Ojo Izquierdo")),
                          RefreshIndicator(
                            onRefresh: _getData,
                            child: ListView.builder(
                              itemCount: _leftDosesModel!.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return Card(
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(_droppersModel!
                                              .singleWhere((dropper) =>
                                                  dropper.id ==
                                                  _leftDosesModel![index]
                                                      .dropperId)
                                              .name),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Flexible(
                                              fit: FlexFit.loose,
                                              child: Text(
                                                _droppersModel!
                                                        .singleWhere((dropper) =>
                                                            dropper.id ==
                                                            _leftDosesModel![
                                                                    index]
                                                                .dropperId)
                                                        .description ??
                                                    "Sin descripción",
                                                overflow: TextOverflow.fade,
                                              )),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 20.0,
                                      ),
                                      Text(
                                        DateFormat(DateFormat.HOUR24_MINUTE)
                                            .format(_leftDosesModel![index]
                                                .applicationDateTime),
                                        overflow: TextOverflow.fade,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ]),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(children: [
                      const Center(child: Text("Ojo Derecho")),
                      ListView.builder(
                        itemCount: _rightDosesModel!.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Card(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(_droppersModel!
                                        .singleWhere((dropper) =>
                                            dropper.id ==
                                            _rightDosesModel![index].dropperId)
                                        .name),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(_droppersModel!
                                            .singleWhere((dropper) =>
                                                dropper.id ==
                                                _rightDosesModel![index]
                                                    .dropperId)
                                            .description ??
                                        "Sin descripción"),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20.0,
                                ),
                                Text(
                                  DateFormat(DateFormat.HOUR24_MINUTE).format(
                                      _rightDosesModel![index]
                                          .applicationDateTime),
                                  overflow: TextOverflow.fade,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ]),
                  ),
                ),
                // },
              ],
            ),
    );
  }
}