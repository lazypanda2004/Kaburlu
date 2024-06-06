import 'package:flutter/material.dart';

class CustIcon extends StatelessWidget {
  const CustIcon(
      {super.key,
      required this.ontap,
      required this.icon,
      required this.width,
      this.height = 50});
  final Function()? ontap;
  final IconData icon;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Icon(
                icon,
                color: Colors.white,
              )),
        ),
      ),
    );
  }
}
