// Import necessary dependencies and files
import 'package:leadflow/services/auth/auth_provider.dart';
import 'package:leadflow/services/auth/auth_user.dart';
import 'package:leadflow/services/auth/firebase_auth_provider.dart';

// Create a class AuthService that implements the AuthProvider interface.
// This class will act as a wrapper around the actual AuthProvider implementation.
class AuthService implements AuthProvider {
  // Store a reference to the actual AuthProvider implementation in a variable.
  final AuthProvider provider;

  // Constructor to initialize the AuthService with the provider implementation.
  // The constructor is marked as constant, meaning the value of 'provider' cannot be changed after initialization.
  const AuthService(this.provider);

  // Factory constructor to create an instance of AuthService with the Firebase AuthProvider implementation.
  // This is a convenience method to make it easier to use the FirebaseAuthProvider.
  factory AuthService.firebase() => AuthService(
        FirebaseAuthProvider(),
      );

  // The following methods are required to implement the AuthProvider interface.
  // They simply delegate the calls to the corresponding methods of the 'provider' variable.

  // Method to create a new user account using the 'provider' implementation.
  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) =>
      provider.createUser(email: email, password: password);

  // Getter method to get the current authenticated user using the 'provider' implementation.
  @override
  AuthUser? get currentUser => provider.currentUser;

  // Method to log in with the provided email and password using the 'provider' implementation.
  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) =>
      provider.logIn(
        email: email,
        password: password,
      );

  // Method to log out the currently authenticated user using the 'provider' implementation.
  @override
  Future<void> logOut() => provider.logOut();

  // Method to send an email verification request to the currently authenticated user using the 'provider' implementation.
  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();

  // Method to initialize the authentication service using the 'provider' implementation.
  // This is typically used to set up any necessary configurations or listeners.
  @override
  Future<void> initialize() => provider.initialize();

  // Method to send a password reset request to the provided email using the 'provider' implementation.
  @override
  Future<void> sendPasswordReset({required String toEmail}) =>
      provider.sendPasswordReset(
        toEmail: toEmail,
      );

  // @override
  // Future<AuthUser> signInWithGoogle() => provider.signInWithGoogle();
}
