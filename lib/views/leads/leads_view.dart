// Import statements
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadflow/const/routes.dart';
import 'package:leadflow/enums/menu_action.dart';
import 'package:leadflow/services/auth/auth_service.dart';
import 'package:leadflow/services/auth/bloc/auth_bloc.dart';
import 'package:leadflow/services/auth/bloc/auth_event.dart';
import 'package:leadflow/services/cloud/cloud_lead.dart';
import 'package:leadflow/services/cloud/firebase_cloud_storage.dart';
import 'package:leadflow/utilities/dialogs/logout_dialog.dart';
import 'package:leadflow/views/leads/lead_list_view.dart';

// LeadsView Widget
class LeadsView extends StatefulWidget {
  const LeadsView({Key? key}) : super(key: key);

  @override
  State<LeadsView> createState() => _LeadsViewState();
}

class _LeadsViewState extends State<LeadsView> {
  // Fields
  late final FirebaseCloudStorage _leadsServices;
  String get userId => AuthService.firebase().currentUser!.id;
  late String _salutation;

  // Get the appropriate salutation based on the time of day
  String _getSalutation() {
    final now = DateTime.now();
    if (now.hour >= 0 && now.hour < 12) {
      return 'Good morning';
    } else if (now.hour >= 12 && now.hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  // Initialize fields in initState
  @override
  void initState() {
    _leadsServices = FirebaseCloudStorage();
    _salutation = _getSalutation();
    super.initState();
  }

  // Build the UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _salutation,
              style: const TextStyle(
                color: Colors.blueGrey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2.0),
          ],
        ),
        actions: [
          // Add lead button
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(createOrUpdateLeadRoute);
            },
            icon: const Icon(
              Icons.add,
              color: Colors.black,
            ),
          ),
          // Logout button in a popup menu
          PopupMenuButton<MenuAction>(
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text(
                    'Log Out',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ];
            },
            color: Colors.black, // Set the background color to black
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    context.read<AuthBloc>().add(
                          const AuthEventLogOut(),
                        );
                  }
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              // Display leads using StreamBuilder
              child: StreamBuilder(
                stream: _leadsServices.allLeads(
                  ownerUserId: userId,
                  appointDate: '',
                ),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        final allLeads = snapshot.data as Iterable<CloudLead>;
                        return LeadsListView(
                          leads: allLeads,
                          onDeleteLead: (lead) async {
                            await _leadsServices.deleteLead(
                              documentId: lead.documentId,
                            );
                          },
                          onTap: (lead) {
                            Navigator.of(context).pushNamed(
                              createOrUpdateLeadRoute,
                              arguments: lead,
                            );
                          },
                        );
                      } else {
                        return Container(); // Placeholder while loading data
                      }
                    default:
                      return Container(); // Placeholder in other cases
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
