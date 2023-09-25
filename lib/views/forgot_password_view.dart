import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadflow/services/auth/bloc/auth_bloc.dart';
import 'package:leadflow/services/auth/bloc/auth_event.dart';
import 'package:leadflow/services/auth/bloc/auth_state.dart';
import 'package:leadflow/utilities/dialogs/error_dialog.dart';
import 'package:leadflow/utilities/dialogs/pasword_reset_email_sent_dialo.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.hasSentEmail) {
            _controller.clear();
            await showPasswordResetSentDialog(context);
          }
          if (state.exception != null) {
            await showErrorDialog(
              context,
              'We could not process your request. Please make sure you are a registered user.',
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'FORGOT PASSWORD',
            textAlign: TextAlign.center,
          ),
          titleTextStyle: const TextStyle(
            // decoration: TextDecoration.underline,
            color: Colors.blue,
            fontSize: 20,
            // fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFffffff),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center items vertically
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Center items horizontally
              children: [
                // const Text(
                //   'If you forgot your password, simply enter your email and we will send you a password reset link',
                //   textAlign: TextAlign.center,
                // ),
                const SizedBox(height: 60.0),
                TextField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  autofocus: false,
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Enter your email address',
                  ),
                ),
                const SizedBox(height: 40.0),
                ElevatedButton(
                  onPressed: () {
                    final email = _controller.text;
                    context.read<AuthBloc>().add(
                          AuthEventForgotPassword(
                            email: email,
                          ),
                        );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(327, 40),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(50),
                      ),
                    ),
                  ),
                  child: const Text(
                    'Send Reset',
                  ),
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                          const AuthEventLogOut(),
                        );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(327, 40),
                    backgroundColor: Colors.red,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(50),
                      ),
                    ),
                  ),
                  child: const Text(
                    'Back',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
