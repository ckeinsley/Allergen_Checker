import 'dart:typed_data';
import 'package:allergen_checker/widgets/checked_word_card.dart';
import 'package:allergen_checker/models/checked_word.dart';
import 'package:flutter/material.dart';

class ImageResult extends StatelessWidget {
  const ImageResult({
    super.key,
    required Uint8List? image,
    required this.checkedWords,
  }) : _image = image;

  final Uint8List? _image;
  final List<CheckedWord> checkedWords;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            _image != null
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.memory(
                      _image,
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
    );
  }
}
