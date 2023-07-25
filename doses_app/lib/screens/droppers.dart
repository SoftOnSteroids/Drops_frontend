import 'package:doses_app/models/api_service.dart';
import 'package:doses_app/models/dropper.dart';
import 'package:doses_app/widgets/indicator_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
          onPressed: () => {
            // ShowDialogDoses(context),
          },
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
      elevation: 1,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.water_drop),
            title: Text(dropper.name),
            subtitle: Text(
              dropper.description ?? "",
              style: TextStyle(color: Colors.black.withOpacity(0.6)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
              style: TextStyle(color: Colors.black.withOpacity(0.6)),
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  // showDialog(context: context, builder: (context) => Dialog( child: FormDoses()),);
                  ShowDialogDoses(context);
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

  void ShowDialogDoses(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => Dialog.fullscreen(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Positioned(
              right: 0.0,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Align(
                  alignment: Alignment.topRight,
                  child: CircleAvatar(
                    radius: 14.0,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.close, color: Colors.red),
                  ),
                ),
              ),
            ),
            Text("Edit Dropper: ${dropper.name}"),
            FormDoses(
              dropper: dropper,
            ),
          ],
        ),
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
      onPressed: () {},
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

class FormDoses extends StatefulWidget {
  final Dropper? dropper;
  const FormDoses({super.key, this.dropper});

  @override
  State<FormDoses> createState() => _FormDosesState();
}

class _FormDosesState extends State<FormDoses> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            TextFormField(
              initialValue: widget.dropper?.name ?? "Write a name",
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Validate returns true if the form is valid, or false otherwise.
                    if (_formKey.currentState!.validate()) {
                      // If the form is valid, display a snackbar. In the real world,
                      // you'd often call a server or save the information in a database.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Saving dropper')),
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
        ));
  }
}
