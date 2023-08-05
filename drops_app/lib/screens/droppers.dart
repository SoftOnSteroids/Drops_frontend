import 'dart:developer';

import 'package:drops_app/models/api_constants.dart';
import 'package:drops_app/models/api_service.dart';
import 'package:drops_app/models/dropper.dart';
import 'package:drops_app/widgets/indicator_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DroppersPageWidget extends StatefulWidget {
  const DroppersPageWidget({super.key});

  @override
  State<DroppersPageWidget> createState() => _DroppersPageWidgetState();
}

class _DroppersPageWidgetState extends State<DroppersPageWidget> {
  late List<Dropper>? _droppersModel = [];

  @override
  void initState() {
    super.initState();
    _getData();
  }

  void _getData() async {
    _droppersModel = await ApiService().getDroppers();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Droppers")),
        body: (_droppersModel == null || _droppersModel!.isEmpty)
            ? Center(
                child: getIndicatorWidget(defaultTargetPlatform),
              )
            : SingleChildScrollView(
                child: Wrap(
                  spacing: 8.0,
                  direction: Axis.horizontal,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    for (final Dropper dropper in _droppersModel!)
                      DropperCard(
                        dropper: dropper,
                      )
                  ],
                ),
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showDialog<String>(
            context: context,
            builder: (BuildContext context) => const FormDosesDialog(),
          ),
          backgroundColor: Colors.green[100],
          child: const Icon(Icons.add),
        ));
  }
}

class DropperCard extends StatelessWidget {
  final Dropper dropper;

  const DropperCard({super.key, required this.dropper});

  @override
  Widget build(BuildContext context) {
    return Card(
      // elevation: 1,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize:MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(Icons.water_drop),
            title: Text(dropper.name),
            subtitle: Text(
              dropper.description ?? "",
              style: TextStyle(color: Colors.black.withOpacity(0.6)),
            ),
          ),
          Text(
            "Pharmacy code: ${dropper.code ?? ""}",
            style: TextStyle(color: Colors.black.withOpacity(0.6)),
          ),
          Text(
            "Place to apply: ${dropper.placeApply}",
            style: TextStyle(color: Colors.black.withOpacity(0.6)),
          ),
          Text(
            "Frequency: ${dropper.frequency}",
            style: TextStyle(color: Colors.black.withOpacity(0.6)),
          ),
          Text(
            "Start Date Time: ${(dropper.startDatetime != null) ? DateFormat("yyyy-MM-dd HH:mm").format(dropper.startDatetime!) : ""}",
            style: TextStyle(color: Colors.black.withOpacity(0.6)),
          ),
          Text(
            "End Day: ${(dropper.endDay != null) ? DateFormat("yyyy-MM-dd").format(dropper.endDay!) : ""}",
            style: TextStyle(color: Colors.black.withOpacity(0.6)),
          ),
          Text(
            "Expiration Day: ${(dropper.dateExpiration != null) ? DateFormat("yyyy-MM-dd").format(dropper.dateExpiration!) : ""}",
            style: TextStyle(color: Colors.black.withOpacity(0.6)),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  // ShowDialogDoses(context);
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => FormDosesDialog(
                      dropper: dropper,
                    ),
                  );
                },
                child: const Text('Edit',
                    style: TextStyle(color: Color(0xFF6200EE))),
              ),
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return DeleteAlertDialog(
                        dropper: dropper,
                      );
                    },
                  );
                },
                child:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
          // Image.asset('assets/card-sample-image.jpg'),
          // Image.asset('assets/card-sample-image-2.jpg'),
        ],
      ),
    );
  }
}

class DeleteAlertDialog extends StatelessWidget {
  final Dropper dropper;

  const DeleteAlertDialog({super.key, required this.dropper});

  @override
  AlertDialog build(BuildContext context) {
    // set up the buttons
    Widget cancelButton = ElevatedButton(
      child: const Text(
        "Cancel",
        style: TextStyle(color: Colors.blue),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget deleteButton = TextButton(
      child: const Text(
        "Delete",
        style: TextStyle(color: Colors.red),
      ),
      onPressed: () {
        ApiService().deleteDropper(dropper).then(
            (response) {
              log("Delete response: ${response.body}");
            });
        // () async {
        //   var response = await ApiService().deleteDropper(dropper);
        //   log("Delete response body: ${response.toString()}");
        // };
        Navigator.pop(context);
      },
    );
    // set up the AlertDialog
    return AlertDialog(
      title: Text("Deleting ${dropper.name}"),
      content: const Text("Do you want to delete the dropper and it doses?"),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            deleteButton,
            cancelButton,
          ],
        ),
      ],
      icon: const Icon(Icons.delete),
      iconColor: Colors.red,
      elevation: 0,
    );
  }
}

class FormDosesDialog extends StatefulWidget {
  final Dropper? dropper;
  const FormDosesDialog({super.key, this.dropper});

  @override
  State<FormDosesDialog> createState() => _FormDosesDialogState();
}

class _FormDosesDialogState extends State<FormDosesDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _codeController = TextEditingController();
  int? _placeApply;
  final _frequencyController = TextEditingController();
  final _startDatetimeController = TextEditingController();
  final _endDayController = TextEditingController();
  final _dateExpirationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (widget.dropper != null) {
      _nameController.text = widget.dropper!.name;
      _descriptionController.text = widget.dropper?.description ?? "";
      _codeController.text = widget.dropper?.code ?? "";
      _placeApply = widget.dropper?.placeApply;
      _frequencyController.text = widget.dropper?.frequency.toString() ?? "";
      _startDatetimeController.text = (widget.dropper?.startDatetime != null)
          ? DateFormat("yyyy-MM-dd HH:mm")
              .format(widget.dropper!.startDatetime!)
          : "";
      _endDayController.text = (widget.dropper?.endDay != null)
          ? DateFormat("yyyy-MM-dd").format(widget.dropper!.endDay!)
          : "";
      _dateExpirationController.text = (widget.dropper?.dateExpiration != null)
          ? DateFormat("yyyy-MM-dd").format(widget.dropper!.dateExpiration!)
          : "";
    }
    return Dialog(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Positioned(
            //   right: 0.0,
            //   child: GestureDetector(
            //     onTap: () {
            //       Navigator.of(context).pop();
            //     },
            //     child: const Align(
            //       alignment: Alignment.topRight,
            //       child: CircleAvatar(
            //         radius: 14.0,
            //         backgroundColor: Colors.white,
            //         child: Icon(Icons.close, color: Colors.red),
            //       ),
            //     ),
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: (widget.dropper != null)
                  ? Text("Modifying ${widget.dropper?.name}")
                  : const Text("New Dropper"),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      TextFormField(
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          decoration: const InputDecoration(
                            labelText: "Name",
                            prefixIcon: Icon(Icons.text_fields),
                          ),
                          // The validator receives the text that the user has entered.
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Please enter some text'
                              : null),
                      TextFormField(
                        controller: _descriptionController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          labelText: "Description",
                          prefixIcon: Icon(Icons.text_fields),
                        ),
                      ),
                      TextFormField(
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Farmacy code",
                          prefixIcon: Icon(Icons.numbers),
                        ),
                      ),
                      DropdownButtonFormField(
                        items: [
                          DropdownMenuItem(
                            value: ApiConstants.leftEye,
                            child: const Text("Left"),
                          ),
                          DropdownMenuItem(
                            value: ApiConstants.rightEye,
                            child: const Text("Right"),
                          ),
                          DropdownMenuItem(
                            value: ApiConstants.bothEyes,
                            child: const Text("Both"),
                          ),
                        ],
                        onChanged: (value) => {_placeApply = value},
                        decoration: const InputDecoration(
                          labelText: "Place to apply",
                          prefixIcon: Icon(Icons.remove_red_eye),
                        ),
                        value: widget.dropper?.placeApply,
                      ),
                      TextFormField(
                        controller: _frequencyController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Frequency in hours",
                          prefixIcon: Icon(Icons.numbers),
                        ),
                      ),
                      TextFormField(
                        controller: _startDatetimeController,
                        keyboardType: TextInputType.datetime,
                        decoration: const InputDecoration(
                          labelText: "Start Datetime",
                          prefixIcon: Icon(Icons.edit_calendar_outlined),
                        ),
                        onTap: () async {
                          await showDatePicker(
                            context: context,
                            initialDate: (_startDatetimeController
                                    .text.isNotEmpty)
                                ? DateTime.parse(_startDatetimeController.text)
                                : DateTime.now(),
                            firstDate: DateTime.now()
                                .subtract(const Duration(days: 365)),
                            lastDate: DateTime.now()
                                .add(const Duration(days: 2 * 365)),
                          ).then((startDay) async {
                            TimeOfDay? startTime = await showTimePicker(
                              context: context,
                              initialTime:
                                  (_startDatetimeController.text.isNotEmpty)
                                      ? TimeOfDay.fromDateTime(DateTime.parse(
                                          _startDatetimeController.text))
                                      : const TimeOfDay(hour: 8, minute: 00),
                            );
                            if (startDay != null && startTime != null) {
                              _startDatetimeController.text =
                                  DateFormat("yyyy-MM-dd HH:mm").format(
                                      DateTime(
                                          startDay.year,
                                          startDay.month,
                                          startDay.day,
                                          startTime.hour,
                                          startTime.minute));
                            }
                          });
                        },
                      ),
                      TextFormField(
                        controller: _endDayController,
                        keyboardType: TextInputType.datetime,
                        decoration: const InputDecoration(
                          labelText: "End Day",
                          prefixIcon: Icon(Icons.edit_calendar_outlined),
                        ),
                        onTap: () async {
                          DateTime? endDay = await showDatePicker(
                            context: context,
                            initialDate: (_endDayController.text.isNotEmpty)
                                ? DateTime.parse(_endDayController.text)
                                : DateTime.now(),
                            firstDate: DateTime.now()
                                .subtract(const Duration(days: 365)),
                            lastDate: DateTime.now()
                                .add(const Duration(days: 2 * 365)),
                          );
                          if (endDay != null) {
                            _endDayController.text =
                                DateFormat("yyyy-MM-dd").format(endDay);
                          }
                        },
                      ),
                      TextFormField(
                        controller: _dateExpirationController,
                        keyboardType: TextInputType.datetime,
                        decoration: const InputDecoration(
                          labelText: "Expiration Date",
                          prefixIcon: Icon(Icons.edit_calendar_outlined),
                        ),
                        onTap: () async {
                          DateTime? expDay = await showDatePicker(
                            context: context,
                            initialDate: (_dateExpirationController
                                    .text.isNotEmpty)
                                ? DateTime.parse(_dateExpirationController.text)
                                : DateTime.now(),
                            firstDate: DateTime.now()
                                .subtract(const Duration(days: 365)),
                            lastDate: DateTime.now()
                                .add(const Duration(days: 2 * 365)),
                          );
                          if (expDay != null) {
                            _dateExpirationController.text =
                                DateFormat("yyyy-MM-dd").format(expDay);
                          }
                        },
                      ),
                      // endDay, dateExpiration,
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Validate returns true if the form is valid, or false otherwise.
                              if (_formKey.currentState!.validate()) {
                                // If the form is valid, display a snackbar. In the real world,
                                // you'd often call a server or save the information in a database.
                                Dropper newDropper = Dropper(
                                  id: widget.dropper?.id ?? "",
                                  name: _nameController.text,
                                  description: _descriptionController.text,
                                  code: _codeController.text,
                                  placeApply: _placeApply,
                                  frequency: (_frequencyController
                                              .text.isNotEmpty &&
                                          _frequencyController.text != 'null')
                                      ? int.tryParse(_frequencyController.text)
                                      : null,
                                  startDatetime: DateTime.tryParse(
                                      _startDatetimeController.text),
                                  endDay:
                                      DateTime.tryParse(_endDayController.text),
                                  dateExpiration: DateTime.tryParse(
                                      _dateExpirationController.text),
                                );
                                ApiService().saveDropper(newDropper);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Saving dropper ${widget.dropper?.name}')),
                                );
                                Navigator.pop(context);
                              }
                            },
                            child: const Text('Save'),
                          ),
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel')),
                        ],
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
