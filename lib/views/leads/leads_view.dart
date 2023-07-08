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

class LeadsView extends StatefulWidget {
  const LeadsView({Key? key}) : super(key: key);

  @override
  State<LeadsView> createState() => _LeadsViewState();
}

class _LeadsViewState extends State<LeadsView> {
  late final FirebaseCloudStorage _leadsServices;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _leadsServices = FirebaseCloudStorage();
    super.initState();
  }

//screen structure
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('My Leads'),
        titleTextStyle: const TextStyle(
          decoration: TextDecoration.underline,
          color: Colors.blue,
          fontSize: 20,
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(createOrUpdateLeadRoute);
            },
            icon: const Icon(
              Icons.add,
              color: Colors.black,
            ),
          ),
          PopupMenuButton<MenuAction>(
            color: Colors.black,
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
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Log Out'),
                ),
              ];
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: ListTile(
                  title: Center(
                    child: Text(
                      '500',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  subtitle: Center(
                    child: Text(
                      'Leads converted: 200',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.normal,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25.0),
            const Text(
              'Recent leads',
              style: TextStyle(
                fontSize: 12,
                decoration: TextDecoration.underline,
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: _leadsServices.allLeads(
                  ownerUserId: userId,
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
                        return const CircularProgressIndicator();
                      }
                    default:
                      return const CircularProgressIndicator();
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
