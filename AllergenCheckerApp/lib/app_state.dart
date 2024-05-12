import 'package:allergen_checker/models/allergen.dart';
import 'package:allergen_checker/models/checked_image.dart';
import 'package:flutter/material.dart';

class MyAppState extends ChangeNotifier {
  List<Allergen> loadedAllergens = [];
  var page = 0;
  var totalCount = 0;
  var favorites = <Allergen>[];
  var history = <CheckedImage>[];

  void updateAllergens(List<Allergen> allergens, int page, int totalCount) {
    page = page;
    loadedAllergens = allergens;
    totalCount = totalCount;
    notifyListeners();
  }

  void toggleFavorite(Allergen selected) {
    if (favorites.contains(selected)) {
      favorites.remove(selected); 
    } else {
      favorites.add(selected);
    }
    notifyListeners();
  }

  void addImageToHistory(CheckedImage image) {
    history.add(image);
    print("ADDED IMAGE TO HISTORY");
    notifyListeners();
  }

  void removeImageFromHistory(CheckedImage image) {
    history.remove(image);
    notifyListeners();
  }

}