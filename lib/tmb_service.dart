import 'package:http/http.dart' as http;
import 'tmb_model.dart';

// Servei per accedir a l'API de TMB (Exercici 4)
class TmbService {
  final String _baseUrl = 'https://api.tmb.cat/v1';
  final String _appId = 'd48b2661';
  final String _appKey = '712a889d8804b25797e3d7e92135d707';

  // Endpoint 1: Obtenir totes les línies de bus
  Future<List<TmbLine>> getBusLines() async {
    final uri = Uri.parse(
      '$_baseUrl/transit/linies/bus?app_id=$_appId&app_key=$_appKey',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return tmbLinesFromJson(response.body);
    } else {
      throw Exception('Error al carregar línies: ${response.statusCode}');
    }
  }

  // Endpoint 2: Obtenir informació d'una parada concreta
  Future<List<TmbStop>> getStop(String stopCode) async {
    final uri = Uri.parse(
      '$_baseUrl/transit/parades/$stopCode?app_id=$_appId&app_key=$_appKey',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return tmbStopsFromJson(response.body);
    } else {
      throw Exception('Error al carregar parada: ${response.statusCode}');
    }
  }

  // Endpoint 3: Obtenir iBus (temps real d'espera) per a una parada
  Future<List<TmbIBus>> getIBus(String stopCode) async {
    final uri = Uri.parse(
      '$_baseUrl/ibus/stops/$stopCode?app_id=$_appId&app_key=$_appKey',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return tmbIBusFromJson(response.body);
    } else {
      throw Exception('Error al carregar iBus: ${response.statusCode}');
    }
  }
}
