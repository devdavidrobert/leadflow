import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:leadflow/services/cloud/cloud_storage_constants.dart';

@immutable
class CloudLead {
  final String documentId;
  final String ownerUserId;
  final String comment;
  final String name;
  final String activity;
  final String appointDate;
  final bool isSale;
  final String package;
  final int phoneNumber;
  final bool isTv;
  const CloudLead(
      {required this.documentId,
      required this.ownerUserId,
      required this.comment,
      required this.activity,
      required this.appointDate,
      required this.isSale,
      required this.isTv,
      required this.name,
      required this.package,
      required this.phoneNumber});
  CloudLead.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName],
        comment = snapshot.data()[textFieldComment] as String,
        name = snapshot.data()[textFieldProspectName] as String,
        activity = snapshot.data()[textFieldActivity] as String,
        appointDate = snapshot.data()[textFieldAppointDate] as String,
        isSale = snapshot.data()[textFieldIsSale] as bool,
        package = snapshot.data()[textFieldPackage] as String,
        phoneNumber = snapshot.data()[textFieldPhoneNumber] as int,
        isTv = snapshot.data()[textFieldIsTv] as bool;

  get status => null;
}
