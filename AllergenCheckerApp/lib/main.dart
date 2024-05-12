import 'package:allergen_checker/allergens_page.dart';
import 'package:allergen_checker/history_page.dart';
import 'package:allergen_checker/image_upload_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'word_check_page.dart';
import 'config.dart';
import 'package:logger/logger.dart';

void main() {
  var apiUrl = 'http://localhost:8080/db';
  var logLevel = Level.debug;
  // var apiUrl = 'https://bnuuyschecker.com/db';
  // var logLevel = Level.info;
  Logger.level = logLevel;
  runApp(AppConfig(
    apiUrl: apiUrl,
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Allergen Checker',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const WordCheckPage();
        break;
      case 1:
        page = const ImageUploadPage();
        break;
      case 2:
        page = const AllergensPage();
        break;
      case 3:
        page = const HistoryPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.photo),
                      label: Text('Upload Image'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.science_rounded),
                      label: Text('Allergens'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.history),
                      label: Text('Image History'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}



