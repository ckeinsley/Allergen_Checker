import 'package:flutter/material.dart';

class AppConfig extends InheritedWidget {
  final String apiUrl;

  const AppConfig({super.key, 
    required this.apiUrl,
    required super.child,
  });

  static AppConfig of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppConfig>()!;
  }

  @override
  bool updateShouldNotify(covariant AppConfig oldWidget) {
    return oldWidget.apiUrl != apiUrl;
  }
}
