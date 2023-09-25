import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadflow/services/auth/auth_exceptions.dart';
import 'package:leadflow/services/auth/bloc/auth_bloc.dart';
import 'package:leadflow/services/auth/bloc/auth_event.dart';
import 'package:leadflow/services/auth/bloc/auth_state.dart';
import 'package:leadflow/utilities/dialogs/error_dialog.dart';

class LoginView extends StatelessWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          // Handle login exceptions gracefully
          if (state.exception is UserNotFoundAuthException) {
            await showErrorDialog(
              context,
              'Cannot find a user with the entered credentials.',
            );
          } else if (state.exception is WrongPasswordAuthException) {
            await showErrorDialog(
              context,
              'Wrong credentials',
            );
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(
              context,
              'Authentication Error',
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(''),
          titleTextStyle: const TextStyle(
            color: Colors.blue,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFFffffff),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Login Title
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/business.png',
                          width: 40,
                          height: 40,
                        )
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Welcome to Your Lead Gen",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  // Email input field
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      controller: _emailController,
                      autocorrect: true,
                      enableSuggestions: true,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'Enter Your Email',
                      ),
                    ),
                  ),
                  // Password input field
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Center(
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        controller: _passwordController,
                        obscureText: true,
                        autocorrect: false,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: const InputDecoration(
                          hintText: 'Enter Your Password',
                        ),
                      ),
                    ),
                  ),

                  // Login button
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () async {
                          final email = _emailController.text;
                          final password = _passwordController.text;
                          context.read<AuthBloc>().add(
                                AuthEventLogIn(email, password),
                              );
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          // Define button styling here
                        ),
                        child: const Text("Login"),
                      ),
                    ),
                  ),
                  // Space in-between
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("-------- OR --------"),
                  ),
                  // Google sign-in
                  Center(
                    child: ClipRRect(
                      child: Card(
                        child: Center(
                          child: InkWell(
                            onTap: () async {
                              // Handle Google sign-in
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () async {},
                                  icon: Image.asset(
                                    'assets/images/google_logo.png',
                                    width: 24,
                                    height: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Microsoft sign-in
                  Center(
                    child: ClipRRect(
                      child: Card(
                        child: Center(
                          child: InkWell(
                            onTap: () async {
                              // Handle Google sign-in
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () async {},
                                  icon: Image.asset(
                                    'assets/images/microsoft.png',
                                    width: 24,
                                    height: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
