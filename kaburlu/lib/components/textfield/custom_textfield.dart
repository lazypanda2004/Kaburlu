import 'package:flutter/material.dart';

class cust_textfield extends StatelessWidget {
  final controller;
  final String hint_text;
  final bool obscure_text;

  const cust_textfield({
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
        controller: controller,
        obscureText: obscure_text,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          hintText: hint_text,
          fillColor: Colors.grey.shade200,
          filled: true,
        ),
      ),
    );
  }
}
