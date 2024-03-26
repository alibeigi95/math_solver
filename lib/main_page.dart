import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  XFile? _image;
  String _responseBody = "";
  String _customPrompt = "";
  bool _isSending = false;
  final TextEditingController _controller = TextEditingController();

  _openCamera() {
    if (_image == null) {
      _getImageFromCamera();
    }
  }

  Future<void> _getImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      ImageCropper cropper = ImageCropper();
      final croppedImage = await cropper.cropImage(
        sourcePath: image.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9,
        ],
        iosUiSettings: const IOSUiSettings(
          title: 'Cropper',
        ),
      );
      setState(() {
        _image = croppedImage != null ? XFile(croppedImage.path) : null;
      });
    }
  }

  Future<void> sendImage(XFile? imageFile) async {
    setState(() {
      _isSending = true;
    });
    if (imageFile == null) return;
    String base64Image = base64Encode(File(imageFile.path).readAsBytesSync());
    String apiKey = "AIzaSyDb21IxZRwIHycdZ_SMCKLfhYCh5T6pprU";

    String requestBody = json.encode(
      {
        "contents": [
          {
            "parts": [
              {
                "text": _customPrompt == ""
                    ? "Solve this maths function and write step-by-step details and the reason behind that step"
                    : _customPrompt
              },
              {
                "inlineData": {
                  "mimeType": "image/png",
                  "data": base64Image,
                }
              }
            ]
          },
        ],
        "generationConfig": {
          "temperature": 0.9,
          "topK": 1,
          "topP": 1,
          "maxOutputTokens": 2048,
          "stopSequences": []
        },
        "safetySettings": [
          {
            "category": "HARM_CATEGORY_HARASSMENT",
            "threshold": "BLOCK_MEDIUM_AND_ABOVE"
          },
          {
            "category": "HARM_CATEGORY_HATE_SPEECH",
            "threshold": "BLOCK_MEDIUM_AND_ABOVE"
          },
          {
            "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
            "threshold": "BLOCK_MEDIUM_AND_ABOVE"
          },
          {
            "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
            "threshold": "BLOCK_MEDIUM_AND_ABOVE"
          }
        ]
      },
    );
    http.Response response = await http.post(
      Uri.parse(
          "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro-vision:generateContent?key=$apiKey"),
      headers: {"Content-Type": "application/json"},
      body: requestBody,
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonBody = json.decode(response.body);
      setState(() {
        _responseBody =
            jsonBody["candidates"][0]["content"]["parts"][0]["text"];
        _isSending = false;
      });
    } else {
      _isSending = false;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Math Solver'),
          backgroundColor: Colors.green[200],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  _image == null
                      ? const Text('No image is selected')
                      : Image.file(File(_image!.path)),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _controller,
                      onChanged: (value) => _customPrompt = value,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _responseBody,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  )
                ],
              ),
            ),
            if (_isSending)
              const Center(
                child: CircularProgressIndicator(),
              )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              !_isSending
                  ? _image == null
                      ? _openCamera()
                      : sendImage(_image)
                  : null;
            });
          },
          tooltip: _image == null ? 'Pick Image' : 'Send image',
          child: Icon(_image == null ? Icons.camera_alt : Icons.send),
        ),
      );
}
