import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leadflow/services/auth/auth_service.dart';
import 'package:leadflow/services/cloud/cloud_lead.dart';
import 'package:leadflow/services/cloud/firebase_cloud_storage.dart';
import 'package:leadflow/utilities/dialogs/cannot_share_empty_lead_dialog.dart';
import 'package:leadflow/utilities/dialogs/generics/get_arguments.dart';
import 'package:share_plus/share_plus.dart';

// CheckboxController class to manage checkbox state
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
  // Initialize required controllers and variables
  late final FirebaseCloudStorage _leadsServices;
  late final TextEditingController _commentController;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _dateController;
  late final TextEditingController _packageController;
  late final TextEditingController _activityController;
  late final TextEditingController _prospectNameController;
  late final CheckboxController _saleCheckboxController;
  String _dateFormat(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  CloudLead? _lead;
  String? _selectedActivity;
  String? _selectedPackage;
  bool _isSale = false;

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

    // Call the _setupTextControllerListener function here
    _setupTextControllerListener();

    super.initState();
  }

  // Function to create or get an existing lead
  Future<CloudLead> createOrGetExistingLead(BuildContext context) async {
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

  // Function to handle changes in the sale checkbox
  void _handleSaleCheckboxValueChanged() {
    bool newValue = _saleCheckboxController.valueNotifier.value;
    setState(() {
      _isSale = newValue;
      if (_isSale) {
        // Set _selectedPackage to a default value for sale
        _selectedPackage = 'Flexx12';
      } else {
        // Set _selectedPackage to a default value for non-sale
        _selectedPackage = 'Shaver';
      }
    });
  }

  // Dispose function to clean up resources
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

  // Function to delete the lead if text fields are empty
  void _deleteLeadIfTextIsEmpty() {
    final lead = _lead;
    if ((_phoneNumberController.text.isEmpty ||
            _prospectNameController.text.isEmpty ||
            _dateController.text.isEmpty ||
            _packageController.text.isEmpty ||
            _activityController.text.isEmpty) &&
        lead != null) {
      _leadsServices.deleteLead(
        documentId: lead.documentId,
      );
    }
  }

  // Function to save the lead if text fields are not empty
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

  // Function to set up text controller listeners
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

  // Listener function for text controllers
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
      appointDate: appointDate,
      isSale: isSale,
      package: package,
      phoneNumber: phone,
      isTv: false,
    );
  }

  // Checkbox widget for the sale option
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New Lead',
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final name = _prospectNameController.text;
              final comment = _commentController.text;
              final phone = _phoneNumberController.text;
              final appointDate = _dateController.text;
              final package = _packageController.text;
              if (_lead == null ||
                  comment.isEmpty ||
                  name.isEmpty ||
                  phone.isEmpty ||
                  package.isEmpty ||
                  appointDate.isEmpty) {
                await showCannotShareEmptyLeadDialog(context);
              } else {
                Share.share(
                  "Name: $name \nPhone: +254$phone \nProduct: $package \nApointment: $appointDate",
                );
              }
            },
            icon: const Icon(
              Icons.share,
              color: Colors.black,
            ),
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
                  // Enter prospect's name
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _prospectNameController,
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      prefixIcon: Icon(Icons.person),
                      labelText: "Prospect's Name",
                      filled: true,
                    ),
                  ),

                  // Enter customer's phone number
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _phoneNumberController,
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      prefixIcon: Icon(Icons.phone),
                      labelText: 'Phone Number',
                      filled: true,
                    ),
                    onChanged: (value) {},
                  ),

                  // Schedule appointment date
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _dateController,
                    textAlign: TextAlign.left,
                    onTap: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          _dateController.text = _dateFormat(selectedDate);
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      prefixIcon: Icon(Icons.calendar_month),
                      labelText: 'Select a Date',
                      filled: true,
                    ),
                  ),

                  // Checkbox for sale
                  const SizedBox(
                    height: 16.0,
                  ),
                  ClipRRect(
                    child: Card(
                      color: Colors.grey[100],
                      child: Center(
                        child: Column(
                          children: [
                            CheckboxListTile(
                              title: const Text('Is a Sale?'),
                              value: _saleCheckboxController.value,
                              onChanged: (value) {
                                setState(() {
                                  _saleCheckboxController.value =
                                      value ?? false;
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Dropdown for selecting the package
                  Visibility(
                    visible: false,
                    child: TextFormField(
                      controller: _packageController,
                      decoration: const InputDecoration(
                        labelText: 'Package',
                      ),
                    ),
                  ),
                  ClipRRect(
                    child: Card(
                      color: Colors.grey[100],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Column(
                            children: [
                              const Text(
                                  'Select Product:'), // Add the label here
                              const SizedBox(width: 10),
                              DropdownButton<String>(
                                value: _selectedPackage,
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedPackage = newValue!;
                                    _packageController.text = newValue;
                                  });
                                },
                                items:
                                    getDropdownItems(), // Call the function to get dropdown items
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Dropdown for selecting the activity
                  Visibility(
                    visible: false,
                    child: TextFormField(
                      controller: _activityController,
                      decoration: const InputDecoration(
                        labelText: 'Activity',
                      ),
                    ),
                  ),
                  ClipRRect(
                    child: Card(
                      color: Colors.grey[100],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Column(
                            children: [
                              const Text(
                                  'Select Activity'), // Add the label here
                              const SizedBox(
                                  width:
                                      10), // Add some spacing between the label and dropdown
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
                                    value: 'MarketStorm',
                                    child: Text('Market Storm'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Homeparty',
                                    child: Text('Homeparty'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'DoorToDoor',
                                    child: Text('Door-to-Door'),
                                  ),
                                  // Add other dropdown items here if needed
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // TextField for entering comments
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

                  // Save Button
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

  List<DropdownMenuItem<String>> getDropdownItems() {
    if (_isSale) {
      return const [
        DropdownMenuItem<String>(
          value: 'Flexx12', // Unique value
          child: Text('Flexx12'),
        ),
        DropdownMenuItem<String>(
          value: 'Flexx40', // Unique value
          child: Text('Flexx40'),
        ),
        DropdownMenuItem<String>(
          value: 'Taa Imara', // Unique value
          child: Text('Taa Imara'),
        ),
        DropdownMenuItem<String>(
          value: '24TV', // Unique value
          child: Text('24" TV'),
        ),
        DropdownMenuItem<String>(
          value: 'SamsungA03', // Unique value
          child: Text('Samsung A03'),
        ),
        DropdownMenuItem<String>(
          value: 'SamsungA13', // Unique value
          child: Text('Samsung A13'),
        ),
        DropdownMenuItem<String>(
          value: 'SamsungA14', // Unique value
          child: Text('Samsung A14'),
        ),
      ];
    } else {
      return const [
        DropdownMenuItem<String>(
          value: 'Shaver', // Unique value
          child: Text('Shaver'),
        ),
        DropdownMenuItem<String>(
          value: 'Sub-woofer', // Unique value
          child: Text('Sub-woofer'),
        ),
        DropdownMenuItem<String>(
          value: 'Upgrade 24" TV', // Unique value
          child: Text('Upgrade 24" TV'),
        ),
      ];
    }
  }
}
