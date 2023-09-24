// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadflow/services/auth/auth_exceptions.dart';
import 'package:leadflow/services/auth/bloc/auth_bloc.dart';
import 'package:leadflow/services/auth/bloc/auth_event.dart';
import 'package:leadflow/services/auth/bloc/auth_state.dart';
import 'package:leadflow/utilities/dialogs/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  get leadflow => null;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          //Log in Exceptions
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
                  Center(
                    child:
                        //Google sign
                        Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () async {
                              try {
                                context
                                    .read<AuthBloc>()
                                    .add(AuthEventSignInWithGoogle());
                              } catch (e) {
                                await showErrorDialog(
                                  context,
                                  '$e',
                                );
                              }
                            },
                            icon: Image.asset(
                              'assets/images/business.png',
                              width: 40,
                              height: 40,
                            ),
                          ),
                          const Text(""),
                        ],
                      ),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: TextField(
                      controller: _email,
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'Enter Your Email',
                      ),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      child: TextField(
                        controller: _password,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: const InputDecoration(
                          hintText: 'Enter Your Password',
                        ),
                      )),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () async {
                          final email = _email.text;
                          final password = _password.text;
                          context.read()<AuthBloc>().add(
                                AuthEventLogIn(email, password),
                              );
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        )),
                        child: const Text("Login"),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("-------- OR --------"),
                  ),
                  Center(
                    child:
                        //Google sign
                        ClipRRect(
                      child: Card(
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  try {
                                    context
                                        .read<AuthBloc>()
                                        .add(AuthEventSignInWithGoogle());
                                  } catch (e) {
                                    await showErrorDialog(
                                      context,
                                      '$e',
                                    );
                                  }
                                },
                                icon: Image.asset(
                                  'assets/images/google_logo.png',
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                              const Text("Sign in with Google"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child:
                        //Google sign
                        ClipRRect(
                      child: Card(
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  try {
                                    context
                                        .read<AuthBloc>()
                                        .add(AuthEventSignInWithGoogle());
                                  } catch (e) {
                                    await showErrorDialog(
                                      context,
                                      '$e',
                                    );
                                  }
                                },
                                icon: Image.asset(
                                  'assets/images/microsoft.png',
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                              const Text("Sign in with Microsoft"),
                            ],
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
