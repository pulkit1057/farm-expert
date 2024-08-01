import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SendImage extends StatefulWidget {
  const SendImage({
    super.key,
    required this.onPickImage,
    required this.selectedImage,
  });

  final File? selectedImage;
  final void Function(File pickedImage) onPickImage;

  @override
  State<SendImage> createState() {
    return _SendImageState();
  }
}

class _SendImageState extends State<SendImage> {
  void _takePicture() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
        source: ImageSource.camera, maxWidth: 600);

    if (pickedImage == null) {
      return;
    }

    final pickedImageFile = File(pickedImage.path);

    setState(() {
      widget.onPickImage(pickedImageFile);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = TextButton.icon(
      icon: const Icon(Icons.camera),
      label: const Text('Take Picture'),
      onPressed: _takePicture,
    );

    if (widget.selectedImage != null) {
      content = GestureDetector(
        onTap: _takePicture,
        child: Image.file(
          widget.selectedImage!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }

    return Container(
      height: 250,
      width: double.infinity,
      alignment: Alignment.center,
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: content,
    );
  }
}
