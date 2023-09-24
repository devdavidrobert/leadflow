import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:leadflow/firebase_options.dart';
import 'package:leadflow/services/auth/auth_exceptions.dart';
import 'package:leadflow/services/auth/auth_provider.dart';
import 'package:leadflow/services/auth/auth_user.dart';

class FirebaseAuthProvider implements AuthProvider {
  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotFoundAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw WeakPasswordAuthException();
      } else if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUseAuthException();
      } else if (e.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    try {
      await Future.delayed(
        const Duration(seconds: 3),
      );
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotFoundAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw UserNotFoundAuthException();
      } else if (e.code == 'wrong-password') {
        throw WrongPasswordAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  Future<void> logOut() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    } else {
      throw UserNotFoundAuthException();
    }
  }

//reset password
  @override
  Future<void> sendPasswordReset({required String toEmail}) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: toEmail,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'firebase_auth/invalid-email':
          throw InvalidEmailAuthException();
        case 'firebase_auth/user-not-found':
          throw UserNotFoundAuthException();
        default:
          throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

//sign in with google
  // @override
  // Future<AuthUser> signInWithGoogle() async {
  //   try {
  //     // Step 1: Start the Google Sign-In flow and get the selected Google account.
  //     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  //     // Step 2: If a Google account is selected, obtain the authentication tokens.
  //     if (googleUser != null) {
  //       final GoogleSignInAuthentication googleAuth =
  //           await googleUser.authentication;

  //       // Step 3: Create an AuthCredential using the obtained access and ID tokens.
  //       final AuthCredential credential = GoogleAuthProvider.credential(
  //         accessToken: googleAuth.accessToken,
  //         idToken: googleAuth.idToken,
  //       );

  //       // Step 4: Sign in to Firebase using the AuthCredential.
  //       final UserCredential authResult =
  //           await FirebaseAuth.instance.signInWithCredential(credential);

  //       // Step 5: Retrieve the Firebase User object from the authentication result.
  //       final user = authResult.user;

  //       // Step 6: If the Firebase User object is not null, return the corresponding AuthUser.
  //       if (user != null) {
  //         // Create the AuthUser object with the name
  //         return AuthUser.fromFirebase(user);
  //       } else {
  //         // Step 7: If the Firebase User object is null, throw a custom exception.
  //         throw UserNotFoundAuthException();
  //       }
  //     } else {
  //       // Step 8: If the Google account is null, throw a custom exception.
  //       throw UserNotFoundAuthException();
  //     }
  //   } catch (_) {
  //     // Step 9: If any error occurs during the process, throw a generic exception.
  //     throw GenericAuthException();
  //   }
  // }
}
