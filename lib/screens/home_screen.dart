import 'package:flutter/material.dart';

// Pantalla principal amb navegació als 4 exercicis
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pràctica 5d - APIs REST'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Exercicis',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            _buildExerciseButton(
              context,
              title: 'Exercici 1 & 2: Llista de Cotxes',
              subtitle: 'API Car Data + Provider + ListView',
              icon: Icons.directions_car,
              color: Colors.blue,
              route: '/cars',
            ),
            const SizedBox(height: 16),
            _buildExerciseButton(
              context,
              title: 'Exercici 3: Acudits',
              subtitle: 'API Sample Jokes - Acudit aleatori',
              icon: Icons.emoji_emotions,
              color: Colors.amber,
              route: '/jokes',
            ),
            const SizedBox(height: 16),
            _buildExerciseButton(
              context,
              title: 'Exercici 4: TMB Barcelona',
              subtitle: 'Línies, parades i iBus en temps real',
              icon: Icons.directions_bus,
              color: Colors.red,
              route: '/tmb',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return Card(
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: color,
          child: Icon(icon, color: Colors.white, size: 30),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}
