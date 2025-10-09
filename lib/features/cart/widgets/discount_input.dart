import 'package:flutter/material.dart';

class DiscountInput extends StatelessWidget {
  final Function(String) onSubmit;

  const DiscountInput({super.key, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: const InputDecoration(labelText: "Gutscheincode eingeben"),
        textInputAction: TextInputAction.done,
        onSubmitted: onSubmit,
      ),
    );
  }
}
