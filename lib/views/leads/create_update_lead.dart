import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leadflow/services/auth/auth_service.dart';
import 'package:leadflow/services/cloud/cloud_lead.dart';
import 'package:leadflow/services/cloud/firebase_cloud_storage.dart';
import 'package:leadflow/utilities/dialogs/cannot_share_empty_lead_dialog.dart';
import 'package:leadflow/utilities/dialogs/generics/get_arguments.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdateLeadView extends StatefulWidget {
  const CreateUpdateLeadView({Key? key}) : super(key: key);

  @override
  State<CreateUpdateLeadView> createState() => _CreateUpdateLeadViewState();
}

class _CreateUpdateLeadViewState extends State<CreateUpdateLeadView> {
  CloudLead? _lead;

  @override
  void initState() {
    _leadsServices = FirebaseCloudStorage();
    _textController = TextEditingController();
    _textController2 = TextEditingController();
    _textController3 = TextEditingController();
    _textController4 = TextEditingController(text: _selectedPackage);
    _textController5 = TextEditingController(text: _selectedActivity);
    _textController6 = TextEditingController();
    super.initState();
  }

  late final FirebaseCloudStorage _leadsServices;
  late final TextEditingController _textController;
  late final TextEditingController _textController2;
  late final TextEditingController _textController3;
  late final TextEditingController _textController4;
  late final TextEditingController _textController5;
  late final TextEditingController _textController6;
  String _selectedActivity = 'Marketstorm';
  String _selectedPackage = 'Flexx12';
  bool _isSale = false;

  void _textControllerListener() async {
    final lead = _lead;
    if (lead == null) {
      return;
    }
    final text = _textController.text;
    final int phone = int.tryParse(_textController2.text) ?? 0;
    final appointDate = _textController3.text;
    final package = _textController4.text;
    final activity = _textController5.text;
    final name = _textController6.text;
    await _leadsServices.updateLead(
      documentId: lead.documentId,
      comment: text,
      name: name,
      activity: activity,
      appointDate:
          appointDate, // Replace this with the appropriate Timestamp value
      isSale: _isSale,
      package: package,
      phoneNumber: phone,
      isTv: false,
    );
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
    _textController2.removeListener(_textControllerListener);
    _textController2.addListener(_textControllerListener);
    _textController3.removeListener(_textControllerListener);
    _textController3.addListener(_textControllerListener);
    _textController4.removeListener(_textControllerListener);
    _textController4.addListener(_textControllerListener);
    _textController5.removeListener(_textControllerListener);
    _textController5.addListener(_textControllerListener);
    _textController6.removeListener(_textControllerListener);
    _textController6.addListener(_textControllerListener);
  }

  Future<CloudLead> createOrGetExistingLead(
    BuildContext context,
  ) async {
    final widgetLead = context.getArgument<CloudLead>();
    if (widgetLead != null) {
      _lead = widgetLead;
      _textController.text = widgetLead.comment;
      _textController6.text = widgetLead.name;
      _textController2.text = widgetLead.phoneNumber.toString();
      _textController3.text = widgetLead.appointDate;
      _textController4.text = widgetLead.package;
      _textController5.text = widgetLead.activity;
      return widgetLead;
    }

    final existingLead = _lead;
    if (existingLead != null) {
      return existingLead;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final newLead = await _leadsServices.createNewLead(ownerUserId: userId);
    _lead = newLead;
    return newLead;
  }

  //deleting a lead => this is called when one exits without writing anything
  void _deleteLeadIfTextIsEmpty() {
    final lead = _lead;
    if (_textController.text.isEmpty && lead != null) {
      _leadsServices.deleteLead(
        documentId: lead.documentId,
      );
    }
  }

  //save a lead
  void _saveLeadIfTextLeadEmpty() async {
    final lead = _lead;
    final text = _textController.text;
    final int phone = int.tryParse(_textController2.text) ?? 0;
    final appointDate = _textController3.text;
    final package = _textController4.text;
    final activity = _textController5.text;
    final name = _textController6.text;
    if (lead != null && text.isNotEmpty) {
      await _leadsServices.updateLead(
        documentId: lead.documentId,
        comment: text,
        name: name,
        activity: activity,
        appointDate: appointDate,
        isSale: false,
        package: package,
        phoneNumber: phone,
        isTv: false,
      );
    }
  }

  @override
  void dispose() {
    _deleteLeadIfTextIsEmpty();
    _saveLeadIfTextLeadEmpty();
    _textController.dispose();
    _textController2.dispose();
    _textController3.dispose();
    _textController4.dispose();
    _textController5.dispose();
    _textController6.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Lead'),
        actions: [
          IconButton(
            onPressed: () async {
              final comment = _textController.text;
              final phone = _textController2.text;
              final appointDate = _textController3.text;
              if (_lead == null ||
                  comment.isEmpty ||
                  phone.isEmpty ||
                  appointDate.isEmpty) {
                await showCannotShareEmptyLeadDialog(context);
              } else {
                Share.share(
                  phone,
                );
              }
            },
            icon: const Icon(Icons.share),
          )
        ],
      ),
      body: FutureBuilder(
        future: createOrGetExistingLead(context),
        builder: (context, snapshot) {
          ConnectionState.done;
          _setupTextControllerListener();
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  //Enter prospect's name
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _textController6,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      alignLabelWithHint: bool.fromEnvironment(
                        'Prospect\'s name',
                      ),
                      labelText: "Prospect's Name",
                    ),
                  ),

                  //Enter customer's phone number
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _textController2,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      alignLabelWithHint: bool.fromEnvironment(
                        'Phone number:',
                      ),
                      labelText: 'Phone Number',
                    ),
                    onChanged: (value) {
                      // Handle phone number changes
                    },
                  ),

                  //Schedule appointment date
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _textController3,
                    textAlign: TextAlign.center,
                    onTap: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (selectedDate != null) {
                        final formattedDate =
                            DateFormat('yyyy-MM-dd').format(selectedDate);
                        setState(() {
                          _textController3.text = formattedDate;
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      alignLabelWithHint: bool.fromEnvironment('Select a Date'),
                      labelText: 'Select a Date',
                    ),
                  ),
                  //is sale?
                  const SizedBox(
                    height: 16.0,
                    width: 16.0,
                  ),
                  CheckboxListTile(
                    title: const Text('Sale'),
                    value: _isSale,
                    onChanged: (value) {
                      setState(() {
                        _isSale = value ?? false;
                      });
                    },
                  ),
                  const SizedBox(height: 16.0),
                  Visibility(
                    visible: false,
                    child: TextFormField(
                      controller: _textController4,
                      decoration: const InputDecoration(
                        labelText: 'Package',
                      ),
                    ),
                  ),
                  DropdownButton<String>(
                    value: _selectedPackage,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedPackage = newValue!;
                        _textController4.text = newValue;
                      });
                    },
                    items: const [
                      DropdownMenuItem<String>(
                        value: 'Flexx12',
                        child: Text('Flexx12'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Flexx40',
                        child: Text('Flexx40'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Taa Imara',
                        child: Text('Taa Imara'),
                      ),
                      DropdownMenuItem<String>(
                        value: '24TV',
                        child: Text('24" TV'),
                      ),
                      DropdownMenuItem<String>(
                        value: '32TV',
                        child: Text('32" TV'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'SamsungA03',
                        child: Text('Samsung A03'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'SamsungA13',
                        child: Text('Samsung A13'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'SamsungA14',
                        child: Text('Samsung A14'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Visibility(
                    visible: false,
                    child: TextFormField(
                      controller: _textController5,
                      decoration: const InputDecoration(
                        labelText: 'Activity',
                      ),
                    ),
                  ),
                  DropdownButton<String>(
                    value: _selectedActivity,
                    onChanged: (newActivity) {
                      setState(() {
                        _selectedActivity = newActivity!;
                        _textController5.text = newActivity;
                      });
                    },
                    items: const [
                      DropdownMenuItem(
                        value: 'Homeparty',
                        child: Text('Homeparty'),
                      ),
                      DropdownMenuItem(
                        value: 'Marketstorm',
                        child: Text('Marketstorm'),
                      ),
                      DropdownMenuItem(
                        value: 'Door-to-door',
                        child: Text('Door-to-door'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _textController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: 'Start typing here',
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      // final email = _email.text;
                      // final password = _password.text;
                      // context.read<CloudLead>().add(
                      //       AuthEventLogIn(
                      //         email,
                      //         password,
                      //       ),
                      //     );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(327, 40),
                      backgroundColor: Colors.green,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(50),
                        ),
                      ),
                    ),
                    child: const Text(
                      'Save',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
