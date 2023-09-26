import 'package:flutter/material.dart';

typedef DialogOptionBuilder<T> = Map<String, T?> Function();

Future<T?> showGenericDialog<T>({
  required BuildContext context,
  required String title,
  required String content,
  required DialogOptionBuilder optionsBuilder,
}) {
  final options = optionsBuilder();
  return showDialog<T>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          title,
          textAlign: TextAlign.center, // Center the title text
          style: const TextStyle(
            fontWeight: FontWeight.bold, // Make the title text bold
            decoration: TextDecoration.underline, // Underline the title text
          ),
        ),
        content: Text(
          content,
          textAlign: TextAlign.center,
        ),
        actions: options.keys.map((optionTitle) {
          final value = options[optionTitle];
          return Center(
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (value != null) {
                      Navigator.of(context).pop(value);
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 40),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(50),
                      ),
                    ),
                  ),
                  child: Text(optionTitle),
                ),
              ],
            ),
          );
        }).toList(),
      );
    },
  );
}
