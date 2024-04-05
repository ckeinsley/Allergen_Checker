import 'package:flutter/material.dart';

class AppConfig extends InheritedWidget {
  final String apiUrl;

  const AppConfig({
    required this.apiUrl,
    required Widget child,
  }) : super(child: child);

  static AppConfig of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppConfig>()!;
  }

  @override
  bool updateShouldNotify(covariant AppConfig oldWidget) {
    return oldWidget.apiUrl != apiUrl;
  }
}
