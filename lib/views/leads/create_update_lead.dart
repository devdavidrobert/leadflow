import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leadflow/services/auth/auth_service.dart';
import 'package:leadflow/services/cloud/cloud_lead.dart';
import 'package:leadflow/services/cloud/firebase_cloud_storage.dart';
import 'package:leadflow/utilities/dialogs/cannot_share_empty_lead_dialog.dart';
import 'package:leadflow/utilities/dialogs/generics/get_arguments.dart';
import 'package:share_plus/share_plus.dart';

class CheckboxController {
  final ValueNotifier<bool> valueNotifier;

  CheckboxController(bool initialValue)
      : valueNotifier = ValueNotifier<bool>(initialValue);

  bool get value => valueNotifier.value;
  set value(bool newValue) => valueNotifier.value = newValue;

  void dispose() {
    valueNotifier.dispose();
  }
}

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
    _commentController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _dateController = TextEditingController();
    _packageController = TextEditingController(text: _selectedPackage);
    _activityController = TextEditingController(text: _selectedActivity);
    _prospectNameController = TextEditingController();
    _saleCheckboxController = CheckboxController(_isSale);
    _saleCheckboxController.valueNotifier
        .addListener(_handleSaleCheckboxValueChanged);

    super.initState();
  }

  late final FirebaseCloudStorage _leadsServices;
  late final TextEditingController _commentController;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _dateController;
  late final TextEditingController _packageController;
  late final TextEditingController _activityController;
  late final TextEditingController _prospectNameController;
  late final CheckboxController _saleCheckboxController;

  String _selectedActivity = 'Marketstorm';
  String _selectedPackage = 'Flexx12';
  final bool _isSale = false;

  void _textControllerListener() async {
    final lead = _lead;
    if (lead == null) {
      return;
    }
    final text = _commentController.text;
    final int phone = int.tryParse(_phoneNumberController.text) ?? 0;
    final appointDate = _dateController.text;
    final package = _packageController.text;
    final activity = _activityController.text;
    final name = _prospectNameController.text;
    final isSale = _saleCheckboxController.value;
    await _leadsServices.updateLead(
      documentId: lead.documentId,
      comment: text,
      name: name,
      activity: activity,
      appointDate:
          appointDate, // Replace this with the appropriate Timestamp value
      isSale: isSale,
      package: package,
      phoneNumber: phone,
      isTv: false,
    );
  }

  void _setupTextControllerListener() {
    _commentController.removeListener(_textControllerListener);
    _commentController.addListener(_textControllerListener);
    _phoneNumberController.removeListener(_textControllerListener);
    _phoneNumberController.addListener(_textControllerListener);
    _dateController.removeListener(_textControllerListener);
    _dateController.addListener(_textControllerListener);
    _packageController.removeListener(_textControllerListener);
    _packageController.addListener(_textControllerListener);
    _activityController.removeListener(_textControllerListener);
    _activityController.addListener(_textControllerListener);
    _prospectNameController.removeListener(_textControllerListener);
    _prospectNameController.addListener(_textControllerListener);
    _saleCheckboxController.valueNotifier
        .removeListener(_handleSaleCheckboxValueChanged);
    _saleCheckboxController.valueNotifier
        .addListener(_handleSaleCheckboxValueChanged);
  }

  Future<CloudLead> createOrGetExistingLead(
    BuildContext context,
  ) async {
    final widgetLead = context.getArgument<CloudLead>();
    if (widgetLead != null) {
      _lead = widgetLead;
      _commentController.text = widgetLead.comment;
      _prospectNameController.text = widgetLead.name;
      _phoneNumberController.text = widgetLead.phoneNumber.toString();
      _dateController.text = widgetLead.appointDate;
      _packageController.text = widgetLead.package;
      _activityController.text = widgetLead.activity;
      _saleCheckboxController.value = widgetLead.isSale;
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
    if (_phoneNumberController.text.isEmpty &&
        _prospectNameController.text.isEmpty &&
        _dateController.text.isEmpty &&
        _packageController.text.isEmpty &&
        _activityController.text.isEmpty &&
        _commentController.text.isEmpty &&
        lead != null) {
      _leadsServices.deleteLead(
        documentId: lead.documentId,
      );
    }
  }

  //save a lead
  void _saveLeadIfTextLeadEmpty() async {
    final lead = _lead;
    final text = _commentController.text;
    final int phone = int.tryParse(_phoneNumberController.text) ?? 0;
    final appointDate = _dateController.text;
    final package = _packageController.text;
    final activity = _activityController.text;
    final name = _prospectNameController.text;
    final isSale = _saleCheckboxController.value;
    if (lead != null && text.isNotEmpty) {
      await _leadsServices.updateLead(
        documentId: lead.documentId,
        comment: text,
        name: name,
        activity: activity,
        appointDate: appointDate,
        isSale: isSale,
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
    _commentController.dispose();
    _phoneNumberController.dispose();
    _dateController.dispose();
    _packageController.dispose();
    _activityController.dispose();
    _prospectNameController.dispose();
    _saleCheckboxController.valueNotifier
        .removeListener(_handleSaleCheckboxValueChanged);
    _saleCheckboxController.dispose();
    super.dispose();
  }

  void _handleSaleCheckboxValueChanged() {
    bool newValue = _saleCheckboxController.valueNotifier.value;
    // Perform actions based on the new checkbox value
    if (newValue) {
    } else {
      // Checkbox is unchecked
    }
  }

  CheckboxListTile buildSaleCheckbox() {
    return CheckboxListTile(
      title: const Text('Sale'),
      value: _saleCheckboxController.value,
      onChanged: (value) {
        setState(() {
          _saleCheckboxController.value = value ?? false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Lead'),
        actions: [
          IconButton(
            onPressed: () async {
              final comment = _commentController.text;
              final phone = _phoneNumberController.text;
              final appointDate = _dateController.text;
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
                    controller: _prospectNameController,
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
                    controller: _phoneNumberController,
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
                    controller: _dateController,
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
                          _dateController.text = formattedDate;
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

                  const SizedBox(
                    height: 16.0,
                    width: 16.0,
                  ),
                  CheckboxListTile(
                    title: const Text('Sale'),
                    value: _saleCheckboxController.value,
                    onChanged: (value) {
                      setState(() {
                        _saleCheckboxController.value = value ?? false;
                      });
                    },
                  ),
                  const SizedBox(height: 16.0),
                  Visibility(
                    visible: false,
                    child: TextFormField(
                      controller: _packageController,
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
                        _packageController.text = newValue;
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
                      controller: _activityController,
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
                        _activityController.text = newActivity;
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
                    controller: _commentController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(
                      label: Text('Comment'),
                      hintText: 'Start typing here',
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
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
