import 'dart:convert';

// Model per a les línies de bus TMB (Exercici 4)
class TmbLine {
  final String? code;
  final String? name;
  final String? origin;
  final String? destination;
  final String? color;

  TmbLine({
    this.code,
    this.name,
    this.origin,
    this.destination,
    this.color,
  });

  factory TmbLine.fromJson(Map<String, dynamic> json) {
    // L'API TMB retorna les propietats dins de "properties"
    final props = json['properties'] as Map<String, dynamic>? ?? json;
    return TmbLine(
      code: props['CODI_LINIA']?.toString(),
      name: props['NOM_LINIA']?.toString(),
      origin: props['ORIGEN_LINIA']?.toString(),
      destination: props['DESTI_LINIA']?.toString(),
      color: props['COLOR_LINIA']?.toString(),
    );
  }
}

// Model per a les parades de bus TMB
class TmbStop {
  final String? code;
  final String? name;
  final String? address;
  final String? municipality;

  TmbStop({
    this.code,
    this.name,
    this.address,
    this.municipality,
  });

  factory TmbStop.fromJson(Map<String, dynamic> json) {
    final props = json['properties'] as Map<String, dynamic>? ?? json;
    return TmbStop(
      code: props['CODI_PARADA']?.toString(),
      name: props['NOM_PARADA']?.toString(),
      address: props['ADRECA']?.toString(),
      municipality: props['NOM_MUNICIPI']?.toString(),
    );
  }
}

// Model per a la informació iBus (temps d'espera en temps real)
class TmbIBus {
  final String? line;
  final String? destination;
  final int? timeInMin;
  final String? text;

  TmbIBus({
    this.line,
    this.destination,
    this.timeInMin,
    this.text,
  });

  factory TmbIBus.fromJson(Map<String, dynamic> json) {
    return TmbIBus(
      line: json['line']?.toString(),
      destination: json['text-ca']?.toString() ?? json['destination']?.toString(),
      timeInMin: json['t-in-min'] as int?,
      text: json['t-in-s']?.toString(),
    );
  }
}

// Funcions de conversió
List<TmbLine> tmbLinesFromJson(String str) {
  final data = json.decode(str);
  final features = data['features'] as List<dynamic>? ?? [];
  return features.map((item) => TmbLine.fromJson(item as Map<String, dynamic>)).toList();
}

List<TmbStop> tmbStopsFromJson(String str) {
  final data = json.decode(str);
  final features = data['features'] as List<dynamic>? ?? [];
  return features.map((item) => TmbStop.fromJson(item as Map<String, dynamic>)).toList();
}

List<TmbIBus> tmbIBusFromJson(String str) {
  final data = json.decode(str);
  final iBusData = data['data'] as Map<String, dynamic>? ?? {};
  final lines = iBusData['ibus'] as List<dynamic>? ?? [];
  return lines.map((item) => TmbIBus.fromJson(item as Map<String, dynamic>)).toList();
}
