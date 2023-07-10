import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

@immutable
class AuthUser {
  final String id;
  final String email;
  final bool isEmailVerified;
  final String diplayname;
  const AuthUser({
    required this.id,
    required this.email,
    required this.isEmailVerified,
    required this.diplayname,
    String? name,
  });

  factory AuthUser.fromFirebase(User user) => AuthUser(
        id: user.uid,
        email: user.email!,
        isEmailVerified: user.emailVerified,
        name: user.displayName,
        diplayname: 'David Robert',
      );
}
