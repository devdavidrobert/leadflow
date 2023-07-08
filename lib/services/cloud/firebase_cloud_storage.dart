import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:leadflow/services/cloud/cloud_lead.dart';
import 'package:leadflow/services/cloud/cloud_storage_constants.dart';
import 'package:leadflow/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final leads = FirebaseFirestore.instance.collection('leads');

  //delete a lead
  Future<void> deleteLead({required String documentId}) async {
    try {
      await leads.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteLeadException();
    }
  }

  //update a lead.
  Future<void> updateLead({
    required String documentId,
    required String comment,
    required String name,
    required String activity,
    required String appointDate,
    required bool isSale,
    required String package,
    required int phoneNumber,
    required bool isTv,
  }) async {
    try {
      await leads.doc(documentId).update(
        {
          textFieldComment: comment,
          textFieldActivity: activity,
          textFieldAppointDate: appointDate,
          textFieldIsSale: isSale,
          textFieldIsTv: isTv,
          textFieldPackage: package,
          textFieldPhoneNumber: phoneNumber,
          textFieldProspectName: name
        },
      );
    } catch (e) {
      throw CouldNotUpdateLeadException();
    }
  }

  //Read leads
  Stream<Iterable<CloudLead>> allLeads({required String ownerUserId}) =>
      leads.snapshots().map((event) => event.docs
          .map((doc) => CloudLead.fromSnapshot(doc))
          .where((lead) => lead.ownerUserId == ownerUserId));

  Future<Iterable<CloudLead>> getLeads({required String ownerUserId}) async {
    try {
      return await leads
          .where(
            ownerUserIdFieldName,
            isEqualTo: ownerUserId,
          )
          .get()
          .then(
            (value) => value.docs.map(
              (doc) => CloudLead.fromSnapshot(doc),
            ),
          );
    } catch (e) {
      throw CouldNotGetAllLeadsException();
    }
  }

  //create new lead
  Future<CloudLead> createNewLead({required String ownerUserId}) async {
    final document = await leads.add(
      {
        ownerUserIdFieldName: ownerUserId,
        textFieldComment: '',
        textFieldProspectName: '',
        textFieldActivity: '',
        textFieldAppointDate: '',
        textFieldIsSale: true,
        textFieldPackage: '',
        textFieldPhoneNumber: 0,
        textFieldIsTv: false
      },
    );
    final fetchedLead = await document.get();
    final data = fetchedLead.data() as Map<String, dynamic>;
    return CloudLead(
      documentId: fetchedLead.id,
      ownerUserId: ownerUserId,
      comment: data[textFieldComment],
      name: data[textFieldProspectName],
      activity: data[textFieldActivity],
      appointDate: data[textFieldAppointDate],
      isSale: data[textFieldIsSale],
      package: data[textFieldPackage],
      phoneNumber: data[textFieldPhoneNumber],
      isTv: data[textFieldIsTv],
    );
  }

  //initialize Firebase
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
