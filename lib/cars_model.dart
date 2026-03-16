import 'dart:convert';

class CarsModel {
  final int? id;
  final int? year;
  final String? make;
  final String? model;
  final String? type;

  CarsModel({
    this.id,
    this.year,
    this.make,
    this.model,
    this.type,
  });

  // Crear un objecte CarsModel a partir d'un Map (JSON decodificat)
  factory CarsModel.fromJson(Map<String, dynamic> json) {
    return CarsModel(
      id: json['id'] as int?,
      year: json['year'] as int?,
      make: json['make'] as String?,
      model: json['model'] as String?,
      type: json['type'] as String?,
    );
  }

  // Convertir un objecte CarsModel a Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'year': year,
      'make': make,
      'model': model,
      'type': type,
    };
  }
}

// Funció per convertir una cadena JSON a una llista de CarsModel
List<CarsModel> carsModelFromJson(String str) {
  final jsonData = json.decode(str) as List<dynamic>;
  return jsonData.map((item) => CarsModel.fromJson(item as Map<String, dynamic>)).toList();
}

// Funció per convertir una llista de CarsModel a cadena JSON
String carsModelToJson(List<CarsModel> data) {
  final jsonData = data.map((car) => car.toJson()).toList();
  return json.encode(jsonData);
}


