import 'package:flutter/material.dart';
import 'package:leadflow/utilities/dialogs/generic_dialog.dart';

Future<void> showCannotShareEmptyLeadDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: 'Sharing',
    content: 'You cannot share an empty lead!',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
