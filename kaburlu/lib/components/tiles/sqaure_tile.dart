import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Square_tile extends StatelessWidget {
  const Square_tile({super.key, this.ontap,required this.image_path});
  final Function()? ontap;
  final String image_path;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        padding: 
        const EdgeInsets.all(5),
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Image.asset(image_path),
        ),
      ),
    );
  }
}
