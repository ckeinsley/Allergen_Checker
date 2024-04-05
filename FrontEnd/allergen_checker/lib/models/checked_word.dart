import 'package:allergen_checker/models/allergen.dart';

class CheckedWord {
  final String word;
  final Allergen? matched;

  CheckedWord({
    required this.word,
    this.matched,
  });

  factory CheckedWord.fromJson(Map<String, dynamic> json) {
    if (json['match'] == null) {
      return CheckedWord(word: json['checked_word'].toString());
    }
    return CheckedWord(word: json['checked_word'].toString(),
      matched: Allergen.fromJson(json['match'])
    );
  }
}