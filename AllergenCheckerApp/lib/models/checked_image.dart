import 'dart:typed_data';

import 'package:allergen_checker/models/checked_word.dart';

class CheckedImage {
  String title;
  final Uint8List image;
  final List<CheckedWord> checkedWords;

  CheckedImage({
    required this.title,
    required this.image,
    required this.checkedWords,
  });

  setTitle(String newTitle) {
    title = newTitle;
  }
}