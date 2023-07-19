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
    return ListView.builder(
      itemCount: leads.length,
      itemBuilder: (context, index) {
        final lead = leads.elementAt(index);

        var now = DateTime.now();
        var formatter = DateFormat('yyyy-MM-dd');
        String formatNow = formatter.format(now);
        var parsedNowDate = DateTime.parse(formatNow);

        var appointmentDate = DateTime.parse(lead.appointDate);
        var formattedAppointmentDate = formatter.format(appointmentDate);
        var parsedAppointmentDate = DateTime.parse(formattedAppointmentDate);
        final remainingDays =
            parsedAppointmentDate.difference(parsedNowDate).inDays;
        // appointmentDate.difference(formatDate).inDays;

        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: ListTile(
            onTap: () {
              onTap(lead);
            },
            leading: CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: 1,
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
    );
  }
}
