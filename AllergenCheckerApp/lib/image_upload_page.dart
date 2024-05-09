import 'dart:typed_data';

import 'package:allergen_checker/checked_word_card.dart';
import 'package:allergen_checker/models/checked_word.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'dart:convert';
import 'config.dart';

class ImageUploadPage extends StatefulWidget {
  const ImageUploadPage({super.key});

  @override
  State<ImageUploadPage> createState() => _ImageUploadPage();
}

class _ImageUploadPage extends State<ImageUploadPage> {
  final logger = Logger();
  List<CheckedWord> checkedWords = [];
  Uint8List? _image;
  bool _isInAsyncCall = false;

  @override
  Widget build(BuildContext context) {
    final apiUrl = AppConfig.of(context).apiUrl;

    Future<void> pickImage() async {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        pickedFile.readAsBytes().then((value) => setState(() {
              _image = value;
            }));
      }
    }

    Future<void> uploadImage() async {
      String endpoint = '$apiUrl/check/image';
      // Create a multipart file from the Uint8List
      setState(() {
        _isInAsyncCall = true;
      });

      var stream = http.ByteStream.fromBytes(_image!);
      var length = _image!.length;
      var multipartFile =
          http.MultipartFile('file', stream, length, filename: 'image.jpg');

      try {
        var request = http.MultipartRequest("POST", Uri.parse(endpoint))
          ..files.add(multipartFile);
        var response = await request.send();

        if (response.statusCode == 200) {
          // Handle successful response
          final Map<String, dynamic> responseData =
              json.decode(await response.stream.bytesToString());
          List<dynamic> results = responseData['checked'];
          List<CheckedWord> words = [];
          for (dynamic result in results) {
            var checkedWord = CheckedWord.fromJson(result);
            words.add(checkedWord);
          }
          setState(() {
            _image = base64.decode(responseData['image']);
            checkedWords = words;
            _isInAsyncCall = false;
          });
        } else {
          // Handle error response
          logger.i('Failed to load data: ${response.statusCode}');
        }
      } catch (e) {
        // Handle exceptions
        logger.e('Exception occurred: $e');
        if (context.mounted) {
          showErrorDialog(context, e.toString());
        }
      }
      setState(() {
        _isInAsyncCall = false;
      });
    }

    return ModalProgressHUD(
        inAsyncCall: _isInAsyncCall,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _image != null
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.memory(
                                _image!,
                                fit: BoxFit.contain,
                              ),
                            )
                          : Container(
                              height: 200,
                            ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: checkedWords.length,
                        itemBuilder: (context, index) {
                          return CheckedWordCard(
                            checkedWord: checkedWords[index],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 100.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                        onPressed: pickImage,
                        child: const Text('Select Image')),
                    ElevatedButton(
                        onPressed: uploadImage,
                        child: const Text('Upload Image')),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  void showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('An Error Occurred Trying to Process the Image'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
          ],
        );
      },
    );
  }
}
