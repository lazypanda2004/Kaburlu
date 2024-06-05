import 'package:flutter/material.dart';

class google_button extends StatelessWidget {
  const google_button(
      {super.key,
      required this.ontap,
      required this.text,
      required this.width});
  final Function()? ontap;
  final String text;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
            child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
          child: Row(
            children: [
              Text(
                text,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Spacer(),
              Image.asset(
                'lib/assets/google_icon.png',
                height: 35,
                width: 35,
              ),
            ],
          ),
        )),
      ),
    );
  }
}
