import 'package:allergen_checker/models/checked_word.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'dart:convert';
import 'config.dart';

class WordCheckPage extends StatefulWidget {
  const WordCheckPage({super.key});

  @override
  State<WordCheckPage> createState() => _WordCheckPageState();
}

class _WordCheckPageState extends State<WordCheckPage> {
  final logger = Logger();
  List<CheckedWord> checkedWords = [];

  String _userInput = '';
  String resultData = '';

  @override
  Widget build(BuildContext context) {
    final apiUrl = AppConfig.of(context).apiUrl;

    Future<void> callApi(List<String> ingredientsToCheck) async {
      String endpoint = '$apiUrl/check/words';
      final jsonData = jsonEncode({'ingredients': ingredientsToCheck});
      logger.d(jsonData);
      try {
        final response = await http.post(Uri.parse(endpoint),
            headers: {
              'accept': 'application/json',
              'Content-Type': 'application/json'
            },
            body: jsonData);

        if (response.statusCode == 200) {
          // Handle successful response
          final Map<String, dynamic> responseData = json.decode(response.body);
          List<dynamic> results = responseData['checked'];
          List<CheckedWord> words = [];
          for (dynamic result in results) {
            var checkedWord = CheckedWord.fromJson(result);
            words.add(checkedWord);
          }
          setState(() {
            checkedWords = words;
          });
        } else {
          // Handle error response
          logger.i('Failed to load data: ${response.statusCode}');
        }
      } catch (e) {
        // Handle exceptions
        logger.e('Exception occurred: $e');
        logger.e(e.toString());
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height*0.25),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Card(
                child: TextField(
                  onChanged: (value) => {
                    setState(() {
                      _userInput = value;
                    })
                  },
                  maxLines: null,
                  decoration: const InputDecoration(
                      hintText: 'Enter comma separated list of ingredients',
                      labelText: 'Ingredients to Check',
                      border: OutlineInputBorder()),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  logger.d(_userInput);
                  List<String> inputList = _userInput
                      .split(',')
                      .where((word) => word.trim().isNotEmpty)
                      .map((e) => e.trim())
                      .toList();
                  callApi(inputList);
                },
                child: const Text('Submit'),
              ),
            ],
          ),
          Expanded(
              child: ListView.builder(
            itemCount: checkedWords.length,
            itemBuilder: (context, index) {
              return CheckedWordCard(
                checkedWord: checkedWords[index],
              );
            },
          ))
        ],
      ),
    );
  }
}

class CheckedWordCard extends StatefulWidget {
  final CheckedWord checkedWord;

  const CheckedWordCard({super.key, required this.checkedWord});

  @override
  ExpandableCardState createState() => ExpandableCardState();
}

class ExpandableCardState extends State<CheckedWordCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    var checkedWord = widget.checkedWord;
    var allergenMatched = checkedWord.matched != null;
    var backgroundColor = Theme.of(context).colorScheme.primary;
    var textColor = Theme.of(context).colorScheme.onPrimary;

    List<Widget> texts = [];
    if (allergenMatched) {
      texts.add(const Divider(
        height: 3,
      ));
      texts.add(Text('Common Name: ${checkedWord.matched!.commonName}',
          style: TextStyle(
              color: allergenMatched ? textColor : null,
              fontWeight: FontWeight.w400)));
      texts.add(Text('Alternate Names:',
          style: TextStyle(
            decoration: TextDecoration.underline,
            decorationColor: textColor.withOpacity(1),
            color: allergenMatched ? textColor : null,
            fontWeight: FontWeight.w200,
          )));
      for (String name in checkedWord.matched!.scientificNames) {
        texts.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            name,
            style: TextStyle(color: allergenMatched ? textColor : null),
          ),
        ));
      }
    }

    return Card(
      color: allergenMatched ? backgroundColor : null,
      margin: const EdgeInsets.all(10.0),
      child: ExpansionTile(
        expandedAlignment: Alignment.centerLeft,
        title: Text(
          checkedWord.word,
          style: TextStyle(
              color: allergenMatched ? textColor : null,
              fontWeight: FontWeight.bold),
        ),
        onExpansionChanged: (value) {
          setState(() {
            _isExpanded = value;
          });
        },
        initiallyExpanded: _isExpanded,
        children: [
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: texts),
                ],
              ))
        ],
      ),
    );
  }
}
