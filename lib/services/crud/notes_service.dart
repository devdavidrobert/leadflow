// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:leadflow/extensions/list/filter.dart';
// import 'package:leadflow/services/crud/crud_exceptions.dart';
// import 'package:path/path.dart' show join;
// import 'package:path_provider/path_provider.dart';
// import 'package:sqflite/sqflite.dart';

// class LeadsServices {
//   Database? _db;

//   List<DatabaseLead> _leads = [];
//   DatabaseUser? _user;

//   static final LeadsServices _shared = LeadsServices._sharedInstance();
//   LeadsServices._sharedInstance() {
//     _leadsStreamController = StreamController<List<DatabaseLead>>.broadcast(
//       onListen: () {
//         _leadsStreamController.sink.add(_leads);
//       },
//     );
//   }
//   factory LeadsServices() => _shared;

//   late final StreamController<List<DatabaseLead>> _leadsStreamController;

//   Stream<List<DatabaseLead>> get allLeads =>
//       _leadsStreamController.stream.filter((lead) {
//         final currentUser = _user;
//         if (currentUser != null) {
//           return lead.userId == currentUser.id;
//         } else {
//           throw UserShouldBeSetBeforeReadingAllLeadsException();
//         }
//       });

//   Future<DatabaseUser> getOrCreateUser({
//     required String email,
//     bool setAsCurrentUser = true,
//   }) async {
//     try {
//       final user = await getUser(email: email);
//       if (setAsCurrentUser) {
//         _user = user;
//       }
//       return user;
//     } on CouldNotFindUserException {
//       final createdUser = await createUser(email: email);
//       if (setAsCurrentUser) {
//         _user = createdUser;
//       }
//       return createdUser;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<void> _cacheLeads() async {
//     final allLeads = await getAllLeads();
//     _leads = allLeads.toList();
//     _leadsStreamController.add(_leads);
//   }

//   Future<DatabaseLead> updateLead({
//     required DatabaseLead lead,
//     required String text,
//   }) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();

//     //ensure the lead exists
//     await getLead(id: lead.id);

//     //update databse
//     final updatesCount = await db.update(
//       leadTable,
//       {
//         textColumn: text,
//         isSyncedWithCloudColumn: 0,
//       },
//       where: 'id = ?',
//       whereArgs: [lead.id],
//     );
//     if (updatesCount == 0) {
//       throw CouldNotUpdateLeadException();
//     } else {
//       final updatedLead = await getLead(id: lead.id);
//       _leads.removeWhere((lead) => lead.id == updatedLead.id);
//       _leads.add(updatedLead);
//       _leadsStreamController.add(_leads);
//       return updatedLead;
//     }
//   }

//   Future<Iterable<DatabaseLead>> getAllLeads() async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final leads = await db.query(
//       leadTable,
//     );
//     return leads.map((leadRow) => DatabaseLead.fromRow(leadRow));
//   }

//   Future<DatabaseLead> getLead({required int id}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final leads = await db.query(
//       leadTable,
//       limit: 1,
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//     if (leads.isEmpty) {
//       throw CouldNotFindLeadException();
//     } else {
//       final lead = DatabaseLead.fromRow(leads.first);
//       _leads.removeWhere((lead) => lead.id == id);
//       _leads.add(lead);
//       _leadsStreamController.add(_leads);
//       return lead;
//     }
//   }

//   Future<int> deleteAllLeads() async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final numberOfDeletions = await db.delete(leadTable);
//     _leads = [];
//     _leadsStreamController.add(_leads);
//     return numberOfDeletions;
//   }

//   Future<void> deleteLead({required int id}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final deletedCount = await db.delete(
//       leadTable,
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//     if (deletedCount == 0) {
//       throw CouldNotDeleteLeadrException();
//     } else {
//       _leads.removeWhere((lead) => lead.id == id);
//       _leadsStreamController.add(_leads);
//     }
//   }

//   Future<DatabaseLead> createLead({required DatabaseUser owner}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();

//     //making that the owner exist in the databse with the correct id
//     final dbUser = await getUser(email: owner.email);
//     if (dbUser != owner) {
//       throw CouldNotFindUserException();
//     }
//     const text = '';
//     //create leads
//     final leadId = await db.insert(leadTable, {
//       userIdColumn: owner.id,
//       textColumn: text,
//       isSyncedWithCloudColumn: 1,
//     });
//     final lead = DatabaseLead(
//       id: leadId,
//       text: text,
//       userId: owner.id,
//       isSyncedWithCloud: true,
//     );
//     _leads.add(lead);
//     _leadsStreamController.add(_leads);
//     return lead;
//   }

//   Future<DatabaseUser> getUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final results = await db.query(
//       userTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (results.isEmpty) {
//       throw CouldNotFindUserException();
//     } else {
//       return DatabaseUser.fromRow(results.first);
//     }
//   }

//   Future<DatabaseUser> createUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final results = await db.query(
//       userTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (results.isNotEmpty) {
//       throw UserAlreadyExistsException();
//     }
//     final userId = await db.insert(userTable, {
//       emailColumn: email.toLowerCase(),
//     });
//     return DatabaseUser(
//       id: userId,
//       email: email,
//     );
//   }

//   Future<void> deleteUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final deletedCount = await db.delete(
//       userTable,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (deletedCount != 1) {
//       throw CouldNotDeleteUserException();
//     }
//   }

//   Database _getDatabaseOrThrow() {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseIsNotOpenException();
//     } else {
//       return db;
//     }
//   }

//   Future<void> close() async {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseIsNotOpenException();
//     } else {
//       await db.close();
//       _db = null;
//     }
//   }

//   Future<void> _ensureDbIsOpen() async {
//     try {
//       await open();
//     } on DatabaseAlreadyOpenException {}
//   }

//   Future<void> open() async {
//     if (_db != null) {
//       throw DatabaseAlreadyOpenException();
//     }
//     try {
//       final docsPath = await getApplicationDocumentsDirectory();
//       final dbPath = join(docsPath.path, dbName);
//       final db = await openDatabase(dbPath);
//       _db = db;

// //create the user table
//       await db.execute(createUserTable);

// //creat lead table
//       await db.execute(createLeadTable);
//       await _cacheLeads();
//     } on MissingPlatformDirectoryException {
//       throw UnableToGetDocumentsDirectory();
//     }
//   }
// }

// @immutable
// class DatabaseUser {
//   final int id;
//   final String email;
//   const DatabaseUser({
//     required this.id,
//     required this.email,
//   });

//   DatabaseUser.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         email = map[emailColumn] as String;

//   @override
//   String toString() => 'Person, ID = $id, email = $email';

//   @override
//   bool operator ==(covariant DatabaseUser other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }

// class DatabaseLead {
//   final int id;
//   final String text;
//   final int userId;
//   final bool isSyncedWithCloud;

//   DatabaseLead({
//     required this.id,
//     required this.text,
//     required this.userId,
//     required this.isSyncedWithCloud,
//   });
//   DatabaseLead.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         userId = map[userIdColumn] as int,
//         text = map[textColumn] as String,
//         isSyncedWithCloud =
//             (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;
//   @override
//   String toString() =>
//       'Lead, ID = $id, userID = $userId, isSyncedWithCloud = $isSyncedWithCloud';
//   @override
//   bool operator ==(covariant DatabaseLead other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }

// const dbName = 'leadflow.db';
// const leadTable = 'lead';
// const userTable = 'user';
// const idColumn = 'id';
// const emailColumn = 'email';
// const userIdColumn = 'user_id';
// const textColumn = 'text';
// const isSyncedWithCloudColumn = 'is_synced_with_cloud';

// const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
// 	                  "email"	TEXT NOT NULL UNIQUE,
// 	                  "id"	INTEGER NOT NULL,
// 	                  PRIMARY KEY("id" AUTOINCREMENT));''';

// const createLeadTable = '''CREATE TABLE IF NOT EXISTS "lead" (
// 	"id"	INTEGER NOT NULL,
// 	"text"	TEXT,
// 	"is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
// 	"user_id"	INTEGER NOT NULL,
// 	FOREIGN KEY("text") REFERENCES "user"("id"),
// 	PRIMARY KEY("id" AUTOINCREMENT)
// );
// ''';
