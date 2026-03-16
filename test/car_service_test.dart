import 'package:flutter_test/flutter_test.dart';
import 'package:api_prueba/cars_model.dart';
import 'package:api_prueba/httpCarService.dart';

void main() {
  // Test 1: Comprovar que el model CarsModel es crea correctament des d'un JSON
  group('CarsModel Tests', () {
    test('fromJson crea un CarsModel correctament', () {
      Map<String, dynamic> jsonData = {
        'id': 1,
        'year': 2020,
        'make': 'Toyota',
        'model': 'Camry',
        'type': 'Sedan',
      };

      CarsModel car = CarsModel.fromJson(jsonData);

      expect(car.id, 1);
      expect(car.year, 2020);
      expect(car.make, 'Toyota');
      expect(car.model, 'Camry');
      expect(car.type, 'Sedan');
    });

    test('toJson retorna un Map correcte', () {
      CarsModel car = CarsModel(
        id: 1,
        year: 2020,
        make: 'Toyota',
        model: 'Camry',
        type: 'Sedan',
      );

      Map<String, dynamic> json = car.toJson();

      expect(json['id'], 1);
      expect(json['year'], 2020);
      expect(json['make'], 'Toyota');
      expect(json['model'], 'Camry');
      expect(json['type'], 'Sedan');
    });

    test('carsModelFromJson converteix JSON string a llista', () {
      String jsonString =
          '[{"id":1,"year":2020,"make":"Toyota","model":"Camry","type":"Sedan"},'
          '{"id":2,"year":2021,"make":"Honda","model":"Civic","type":"Coupe"}]';

      List<CarsModel> cars = carsModelFromJson(jsonString);

      expect(cars.length, 2);
      expect(cars[0].make, 'Toyota');
      expect(cars[1].make, 'Honda');
    });
  });

  // Test 2: Test d'integració - connexió real al servei (requereix clau vàlida)
  group('HttpCarService Integration Tests', () {
    test('getCars retorna una llista de cotxes del servei', () async {
      final service = HttpCarService();

      try {
        List<CarsModel> cars = await service.getCars(limit: 5);

        // Comprovem que retorna dades
        expect(cars, isNotEmpty);
        expect(cars.length, lessThanOrEqualTo(5));

        // Comprovem que els objectes tenen dades
        for (var car in cars) {
          expect(car.make, isNotNull);
          expect(car.model, isNotNull);
          expect(car.year, isNotNull);
          print('Cotxe: ${car.year} ${car.make} ${car.model} (${car.type})');
        }
      } catch (e) {
        // Si la clau API no és vàlida, el test informarà de l'error
        print('Error de connexió (comprova la clau API): $e');
        // Marquem el test com a skip si no hi ha clau vàlida
        fail('No s\'ha pogut connectar al servei. Comprova que la clau API és vàlida.');
      }
    });
  });
}
