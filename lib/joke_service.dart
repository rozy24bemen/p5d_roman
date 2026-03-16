import 'package:http/http.dart' as http;
import 'joke_model.dart';

// Servei per obtenir acudits de l'API (Exercici 3)
class JokeService {
  final String _endpoint = 'https://api.sampleapis.com/jokes/goodJokes';

  // Obtenir tots els acudits
  Future<List<JokeModel>> getJokes() async {
    final response = await http.get(Uri.parse(_endpoint));

    if (response.statusCode == 200) {
      return jokeModelFromJson(response.body);
    } else {
      throw Exception('Error al carregar acudits: ${response.statusCode}');
    }
  }
}
