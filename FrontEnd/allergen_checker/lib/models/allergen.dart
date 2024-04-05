class Allergen {
  final String commonName;
  final List<String> scientificNames;

  Allergen({
    required this.commonName,
    required this.scientificNames,
  });

  factory Allergen.fromJson(dynamic json) {
    List<String> scientifics = json['scientific_names'].map<String>((item) => item.toString()).toList();
    return Allergen(commonName: json['common_name'],
      scientificNames: scientifics
    );
  }
}