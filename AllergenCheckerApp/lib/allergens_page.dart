import 'dart:convert';
import 'package:allergen_checker/app_state.dart';
import 'package:http/http.dart' as http;
import 'package:allergen_checker/config.dart';
import 'package:allergen_checker/models/allergen.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class AllergensPage extends StatefulWidget {
  const AllergensPage({super.key});

  @override
  State<AllergensPage> createState() => _AllergensPageState();
}

class _AllergensPageState extends State<AllergensPage> {
  final logger = Logger();

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final apiUrl = AppConfig.of(context).apiUrl;
    const limit = 10;

    Future<void> callApi() async {
      String endpoint = '$apiUrl/database';
      try {
        final response = await http.get(
          Uri.parse(endpoint).replace(queryParameters: {
            'skip': (limit * appState.page).toString(),
            'limit': limit.toString(),
          }),
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/json'
          },
        );

        if (response.statusCode == 200) {
          var jsonData = json.decode(response.body);
          logger.d(jsonData);
          setState(() {
            appState.loadedAllergens = jsonData['allergens']
                .map<Allergen>((item) => Allergen.fromJson(item))
                .toList();
            appState.totalCount = jsonData['total'];
          });
        } else {
          logger.i('Failed to load data: ${response.statusCode}');
        }
      } catch (e) {
        logger.e('Exception occurred: $e');
        logger.e(e.toString());
      }
    }

    if (appState.loadedAllergens.isEmpty) {
      callApi();
      return const Center(
        child: Text('Loading Allergen List'),
      );
    }

    List<Widget> pageButtons = [];
    for (int i = 0; i <= appState.totalCount/limit; i++) {
      pageButtons.add(ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
              i == appState.page
                  ? Theme.of(context).highlightColor
                  : Theme.of(context).cardColor
            ),
          ),
          onPressed: (() => setState(() {
                appState.page = i;
                callApi();
              })),
          child: Text('${i+1}')));
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('Allergens',
              style: Theme.of(context).textTheme.headlineMedium),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: pageButtons,
          ),
        ),
        for (var favorite in appState.loadedAllergens)
          ExpandableCard(
            allergen: favorite,
          )
      ],
    );
  }
}

class ExpandableCard extends StatefulWidget {
  final Allergen allergen;

  const ExpandableCard({super.key, required this.allergen});

  @override
  ExpandableCardState createState() => ExpandableCardState();
}

class ExpandableCardState extends State<ExpandableCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10.0),
      child: ExpansionTile(
        expandedAlignment: Alignment.centerLeft,
        title: Text(
          widget.allergen.commonName,
          style: const TextStyle(fontWeight: FontWeight.bold),
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
                      children: widget.allergen.scientificNames
                          .map((item) => Text(
                                item,
                              ))
                          .toList()),
                ],
              ))
        ],
      ),
    );
  }
}
