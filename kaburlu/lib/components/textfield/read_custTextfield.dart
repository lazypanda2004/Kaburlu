import 'package:flutter/material.dart';

class ReadCusttextfield extends StatelessWidget {
  final TextEditingController? controller;
  final String hint_text;
  final bool obscure_text;

  const ReadCusttextfield({
    super.key,
    required this.hint_text,
    this.obscure_text = false,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: TextField(
        style: TextStyle(color: Colors.white),
        readOnly: true,
        controller: controller,
        obscureText: obscure_text,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          hintText: hint_text,
          fillColor: Colors.black,
          filled: true,
        ),
      ),
    );
  }
}
