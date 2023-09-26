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
      // Extract dates from strings
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

    // Build the UI
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              // Card displaying total number of leads
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
        // Header for recent leads
        const Text(
          'RECENT LEADS',
          textAlign: TextAlign.end,
          style: TextStyle(
            fontSize: 12,
          ),
        ),
        Expanded(
          // List view of sorted leads
          child: ListView.builder(
            itemCount: sortedLeads.length,
            itemBuilder: (context, index) {
              final lead = sortedLeads[index];

              // Calculate remaining days
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

              // Set circleColor based on remaining days
              Color circleColor;
              if (remainingDays < 0) {
                circleColor = Colors.red;
              } else if (remainingDays == 0) {
                circleColor = Colors.green;
              } else {
                circleColor = Colors.blue;
              }

              return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 3,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          )
                        ]),
                    height: 60,
                    child: Center(
                      child: InkWell(
                        onTap: () {
                          onTap(lead);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, top: 12, bottom: 10),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 15,
                                backgroundColor: circleColor,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    remainingDays.toString(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lead.name,
                                      maxLines: 1,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                      lead.package,
                                      maxLines: 1,
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 9,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                      lead.appointDate,
                                      maxLines: 1,
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 9,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Column(
                                children: [
                                  CircleAvatar(
                                    radius: 15,
                                    backgroundColor: Colors.green[100],
                                    child: Align(
                                      alignment: Alignment.center,
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
                                        icon: const Icon(
                                          Icons.call,
                                          size: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ));
            },
          ),
        ),
      ],
    );
  }
}
