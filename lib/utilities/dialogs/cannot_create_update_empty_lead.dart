import 'package:flutter/material.dart';
import 'package:leadflow/utilities/dialogs/generic_dialog.dart';

Future<void> showCannotCreateUpdateEmptyLead(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: 'Create/Update',
    content: 'You cannot create an empty lead!',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
