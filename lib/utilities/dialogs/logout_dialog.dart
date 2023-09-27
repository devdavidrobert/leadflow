import 'package:flutter/material.dart';
import 'package:leadflow/utilities/dialogs/generic_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Log out',
    content: 'Are you sure you want to log out?',
    optionsBuilder: () => {
      'Log out': true,
      'Cancel': false,
    },
  ).then(
    (value) => value ?? false,
  );
}
