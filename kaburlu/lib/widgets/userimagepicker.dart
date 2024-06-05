import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class Userimagepicker extends StatefulWidget {
  const Userimagepicker({
    super.key,
    required this.onPickImage,
  });
  final void Function(File pickedimage) onPickImage;

  @override
  State<Userimagepicker> createState() {
    return _Userimagepickerstate();
  }
}

class _Userimagepickerstate extends State<Userimagepicker> {
  File? _pickedImageFile;

  void _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
      maxWidth: 150,
    );

    if (pickedImage == null) {
      return;
    }
    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });

    widget.onPickImage(_pickedImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor:
                Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            foregroundImage:
                _pickedImageFile != null ? FileImage(_pickedImageFile!) : null,
            child: _pickedImageFile == null
                ? const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.black,
                  )
                : null,
          ),
          TextButton.icon(
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all(Colors.black),
            ),
            onPressed: _pickImage,
            icon: const Icon(Icons.image),
            label: const Text(
              'Add Image',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          )
        ],
      ),
    );
  }
}
