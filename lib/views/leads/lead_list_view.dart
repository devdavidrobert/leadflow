import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leadflow/services/cloud/cloud_lead.dart';
import 'package:url_launcher/url_launcher.dart';

typedef LeadCallback = void Function(CloudLead lead);

class LeadsListView extends StatelessWidget {
  final Iterable<CloudLead> leads;
  final LeadCallback onDeleteLead;
  final LeadCallback onTap;

  const LeadsListView({
    Key? key,
    required this.leads,
    required this.onDeleteLead,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sort leads by remainingDays in ascending order
    List<CloudLead> sortedLeads = [...leads];
    sortedLeads.sort((a, b) {
      var now = DateTime.now();
      var formatter = DateFormat('yyyy-MM-dd');
      String formatNow = formatter.format(now);
      var parsedNowDate = DateTime.parse(formatNow);

      var appointmentDateA = DateTime.parse(a.appointDate);
      var formattedAppointmentDateA = formatter.format(appointmentDateA);
      var parsedAppointmentDateA = DateTime.parse(formattedAppointmentDateA);
      final remainingDaysA =
          parsedAppointmentDateA.difference(parsedNowDate).inDays;

      var appointmentDateB = DateTime.parse(b.appointDate);
      var formattedAppointmentDateB = formatter.format(appointmentDateB);
      var parsedAppointmentDateB = DateTime.parse(formattedAppointmentDateB);
      final remainingDaysB =
          parsedAppointmentDateB.difference(parsedNowDate).inDays;

      return remainingDaysA.compareTo(remainingDaysB);
    });

    var totalLeads = sortedLeads.length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ListTile(
                      title: Center(
                        child: Text(
                          totalLeads.toString(),
                          style: const TextStyle(
                            fontSize: 25,
                          ),
                        ),
                      ),
                      subtitle: const Center(
                        child: Text(
                          'LEADS CREATED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.normal,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 25.0),
        const Text(
          'RECENT LEADS',
          textAlign: TextAlign.end,
          style: TextStyle(
            fontSize: 12,
            // decoration: TextDecoration.underline,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: sortedLeads.length,
            itemBuilder: (context, index) {
              final lead = sortedLeads[index];

              var now = DateTime.now();
              var formatter = DateFormat('yyyy-MM-dd');
              String formatNow = formatter.format(now);
              var parsedNowDate = DateTime.parse(formatNow);

              var appointmentDate = DateTime.parse(lead.appointDate);
              var formattedAppointmentDate = formatter.format(appointmentDate);
              var parsedAppointmentDate =
                  DateTime.parse(formattedAppointmentDate);
              final remainingDays =
                  parsedAppointmentDate.difference(parsedNowDate).inDays;

              return Card(
                child: ListTile(
                  onTap: () {
                    onTap(lead);
                  },
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        remainingDays.toString(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  title: Text(
                    lead.name,
                    maxLines: 1,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  subtitle: Text(
                    lead.package,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 10,
                    ),
                  ),
                  trailing: CircleAvatar(
                    backgroundColor: Colors.green[100],
                    child: IconButton(
                      onPressed: () async {
                        final callPhone = lead.phoneNumber;
                        final Uri url = Uri(
                          scheme: 'tel',
                          path: "+254$callPhone",
                        );
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                      icon: const Icon(Icons.call),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
