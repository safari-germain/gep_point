import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gep_point/components/v_gep_primary_b.dart';
import 'package:gep_point/constants.dart';
import 'package:image_picker/image_picker.dart';

class Step3Profile extends StatefulWidget {
  final Function(File?) onComplete;

  const Step3Profile({super.key, required this.onComplete});

  @override
  State<Step3Profile> createState() => _Step3ProfileState();
}

class _Step3ProfileState extends State<Step3Profile> {
  File? _image;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Photo de Profil (Optionnel)",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: defaultPadding),
        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[300],
            backgroundImage: _image != null ? FileImage(_image!) : null,
            child: _image == null
                ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                : null,
          ),
        ),
        const SizedBox(height: defaultPadding),
        SizedBox(
          width: double.infinity,
          child: VGepPrimaryButton(
             onPressed: () => widget.onComplete(_image),
             text: "Terminer",
          ),
        ),
        TextButton(
          onPressed: () => widget.onComplete(null),
          child: const Text("Passer"),
        ),
      ],
    );
  }
}
