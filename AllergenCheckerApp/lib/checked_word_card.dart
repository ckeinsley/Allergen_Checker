import 'package:allergen_checker/models/checked_word.dart';
import 'package:flutter/material.dart';

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
