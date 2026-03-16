import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../car_provider.dart';

// Pantalla que mostra la llista de cotxes amb un ListView (Exercici 2)
class CarsListScreen extends StatefulWidget {
  const CarsListScreen({super.key});

  @override
  State<CarsListScreen> createState() => _CarsListScreenState();
}

class _CarsListScreenState extends State<CarsListScreen> {
  @override
  void initState() {
    super.initState();
    // Carreguem els cotxes quan s'inicia la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<CarProvider>().loadCars();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Llista de Cotxes'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<CarProvider>(
        builder: (context, carProvider, child) {
          // Mostrem un indicador de càrrega
          if (carProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Mostrem l'error si n'hi ha
          if (carProvider.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    carProvider.error,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => carProvider.loadCars(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          // Mostrem la llista de cotxes
          if (carProvider.cars.isEmpty) {
            return const Center(child: Text('No s\'han trobat cotxes'));
          }

          return ListView.builder(
            itemCount: carProvider.cars.length,
            itemBuilder: (context, index) {
              final car = carProvider.cars[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.directions_car, size: 40),
                  title: Text(
                    '${car.make ?? "Desconegut"} ${car.model ?? ""}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Any: ${car.year ?? "N/A"} - Tipus: ${car.type ?? "N/A"}',
                  ),
                  trailing: Text(
                    '#${car.id ?? ""}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<CarProvider>().loadCars();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
