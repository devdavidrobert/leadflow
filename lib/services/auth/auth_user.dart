import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

@immutable
class AuthUser {
  final String id;
  final String email;
  final bool isEmailVerified;
  final String? name;
  final String? phoneNumber;
  const AuthUser({
    required this.id,
    required this.email,
    required this.isEmailVerified,
    this.phoneNumber,
    this.name,
  });

  factory AuthUser.fromFirebase(User user) => AuthUser(
        id: user.uid,
        email: user.email!,
        isEmailVerified: user.emailVerified,
        phoneNumber: user.phoneNumber,
        name: user.displayName,
      );
  // Named constructor to create a new AuthUser instance with an updated name
  AuthUser withName(String name) {
    return AuthUser(
      id: id,
      email: email,
      isEmailVerified: isEmailVerified,
      phoneNumber: phoneNumber,
      name: name,
    );
  }
}
