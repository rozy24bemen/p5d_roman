import 'package:flutter/material.dart';
import 'cars_model.dart';
import 'httpCarService.dart';

// Provider que gestiona l'estat de la llista de cotxes
class CarProvider extends ChangeNotifier {
  List<CarsModel> _cars = [];
  bool _isLoading = false;
  String _error = '';

  List<CarsModel> get cars => _cars;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Mètode per carregar els cotxes des del servei
  Future<void> loadCars() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final service = HttpCarService();
      _cars = await service.getCars(limit: 10);
    } catch (e) {
      _error = 'Error al carregar cotxes: $e';
    }

    _isLoading = false;
    notifyListeners();
  }
}
