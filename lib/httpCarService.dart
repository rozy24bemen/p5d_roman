import 'package:http/http.dart' as http;
import 'cars_model.dart';

class HttpCarService {
  // URL base del servei
  final String _endpoint = 'https://car-data.p.rapidapi.com/cars';
  // Clau d'accés al servei RapidAPI (substituir per la teva)
  final String _key = 'c4cb5999b7msha98302d04ff2ab8p1ddb7bjsn6514bd875a4c';
  // Host del servei
  final String _host = 'car-data.p.rapidapi.com';

  // Mètode per obtenir la llista de cotxes del servei
  Future<List<CarsModel>> getCars({int limit = 10}) async {
    final uri = Uri.parse('$_endpoint?limit=$limit');

    final response = await http.get(
      uri,
      headers: {
        'X-RapidAPI-Key': _key,
        'X-RapidAPI-Host': _host,
      },
    );

    if (response.statusCode == 200) {
      // Decodifiquem el JSON i retornem la llista de CarsModel
      return carsModelFromJson(response.body);
    } else {
      throw Exception('Error al carregar cotxes: ${response.statusCode}');
    }
  }
}