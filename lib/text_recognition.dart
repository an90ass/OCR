import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/services.dart';     

class TextRecognitionScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TextRecognitionScreenState();
  }
}

class _TextRecognitionScreenState extends State<TextRecognitionScreen> {
  File? _image;
  String? text;

  Future _pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      setState(() {
        _image = File(image.path);
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future textRecognition(File img) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final inputImage = InputImage.fromFilePath(img.path);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    if (recognizedText.text.isEmpty) {
      text = "";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'The current image has no text.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          backgroundColor: Colors.red[700],
        ),
      );
    } else {
      setState(() {
        text = recognizedText.text.replaceAll('\n', ' '); 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Text Recognition",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.deepPurple,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildImageContainer(),
                SizedBox(
                  height: 20.0,
                ),
                buildOpenCameraButton(),
                SizedBox(
                  height: 10.0,
                ),
                buildGalleryButton(),
                SizedBox(
                  height: 20.0,
                ),
                SelectableText(
                  text ?? 'No text recognized yet.',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(
                  height: 10.0,
                ),
                     if (text != null && text!.isNotEmpty)
                      buildCopyButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
 Widget buildImageContainer() {
  return Container(
                  width: double.infinity,
                  height: 250,
                  color: Colors.grey,
                  child: Center(
                    child: _image == null
                        ? Icon(
                            Icons.add_a_photo,
                            size: 60,
                          )
                        : Image.file(_image!),
                  ),
                );
 }
 
  Widget buildOpenCameraButton() {
    return Container(
                  width: double.infinity,
                  height: 50.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.deepPurple,
                  ),
                  child: MaterialButton(
                    onPressed: () {
                      _pickImage(ImageSource.camera).then((value) {
                        if (_image != null) {
                          textRecognition(_image!);
                        }
                      });
                    },
                    child: Text(
                      "Open Camera",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
  }
  
  buildGalleryButton() {
    Container(
                  width: double.infinity,
                  height: 50.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.deepPurple,
                  ),
                  child: MaterialButton(
                    onPressed: () {
                      _pickImage(ImageSource.gallery).then((value) {
                        if (_image != null) {
                          textRecognition(_image!);
                        }
                      });
                    },
                    child: Text(
                      "Pick Image from Gallery",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
  }
  
  Widget buildCopyButton() {
                 return Container(
                    width: double.infinity,
                    height: 50.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.deepPurple,
                    ),
                    child: MaterialButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: text!)).then((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Text copied to clipboard!',
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        });
                      },
                      child: Text(
                        "Copy Text",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
  }
}
