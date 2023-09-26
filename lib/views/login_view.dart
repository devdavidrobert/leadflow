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
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

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
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: SizedBox(
              height: 450,
              width: 300,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
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
                              width: 50,
                              height: 50,
                            )
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Welcome to Your Lead Gen",
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      // Email input field
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 8),
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          controller: emailController,
                          autocorrect: true,
                          enableSuggestions: true,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: const InputDecoration(
                              fillColor: Colors.lightBlue,
                              hintText: 'Enter Your Email',
                              hintStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.normal,
                                fontSize: 11,
                              )),
                        ),
                      ),
                      // Password input field
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 8),
                        child: Center(
                          child: TextFormField(
                            textAlign: TextAlign.center,
                            controller: passwordController,
                            obscureText: true,
                            autocorrect: false,
                            keyboardType: TextInputType.visiblePassword,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: const InputDecoration(
                                hintText: 'Enter Your Password',
                                hintStyle: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.normal,
                                  fontSize: 11,
                                )),
                          ),
                        ),
                      ),

                      // Login button
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 30,
                          child: ElevatedButton(
                            onPressed: () async {
                              final email = emailController.text;
                              final password = passwordController.text;
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
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Space in-between
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "-------- OR --------",
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
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
                                        width: 15,
                                        height: 15,
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
                                        width: 15,
                                        height: 15,
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
        ),
        bottomNavigationBar:
            BottomNavigationBar(backgroundColor: Colors.blue, items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          )
        ]),
      ),
    );
  }
}
