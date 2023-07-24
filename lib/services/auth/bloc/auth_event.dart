import 'package:flutter/foundation.dart' show immutable;

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

//initialize
class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

//send email verification
class AuthEventSendEmailVerification extends AuthEvent {
  const AuthEventSendEmailVerification();
}

//log in
class AuthEventLogIn extends AuthEvent {
  final String email;
  final String password;
  const AuthEventLogIn(
    this.email,
    this.password,
  );
}

//register event
class AuthEventRegister extends AuthEvent {
  final String email;
  final String password;
  const AuthEventRegister(
    this.email,
    this.password,
  );
}

class AuthEventSignInWithGoogle extends AuthEvent {}

//should register
class AuthEventShouldRegister extends AuthEvent {
  const AuthEventShouldRegister();
}

//log out
class AuthEventLogOut extends AuthEvent {
  const AuthEventLogOut();
}

//forgot password event
class AuthEventForgotPassword extends AuthEvent {
  final String? email;
  const AuthEventForgotPassword({this.email});
}
