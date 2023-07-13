// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadflow/services/auth/bloc/auth_bloc.dart';
import 'package:leadflow/services/auth/bloc/auth_event.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  _VerifyEmailViewState createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'VERIFY E-MAIL',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 20,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "We've sent you a verification email. Please open it to verify.",
              ),
              const Text(
                'If you haven\'t received a verification email yet, press the button below',
              ),

              //Send email verification button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                          const AuthEventSendEmailVerification(),
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
                    'Send email verification',
                  ),
                ),
              ),

              //Restart button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () async {
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
                  child: const Text('Restart'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
