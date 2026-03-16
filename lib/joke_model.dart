import 'dart:convert';

// Model per als acudits (Exercici 3)
class JokeModel {
  final int? id;
  final String? setup;
  final String? punchline;

  JokeModel({
    this.id,
    this.setup,
    this.punchline,
  });

  // Crear un JokeModel a partir d'un Map
  factory JokeModel.fromJson(Map<String, dynamic> json) {
    return JokeModel(
      id: json['id'] as int?,
      setup: json['setup'] as String?,
      punchline: json['punchline'] as String?,
    );
  }

  // Convertir a Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'setup': setup,
      'punchline': punchline,
    };
  }
}

// Convertir JSON string a llista de JokeModel
List<JokeModel> jokeModelFromJson(String str) {
  final jsonData = json.decode(str) as List<dynamic>;
  return jsonData.map((item) => JokeModel.fromJson(item as Map<String, dynamic>)).toList();
}
