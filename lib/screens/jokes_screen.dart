import 'dart:math';
import 'package:flutter/material.dart';
import '../joke_model.dart';
import '../joke_service.dart';

// Pantalla d'acudits aleatoris (Exercici 3)
// Separació clara: Vista (JokesScreen) - Controlador (JokeService) - Model (JokeModel)
class JokesScreen extends StatefulWidget {
  const JokesScreen({super.key});

  @override
  State<JokesScreen> createState() => _JokesScreenState();
}

class _JokesScreenState extends State<JokesScreen> {
  final JokeService _jokeService = JokeService();
  List<JokeModel> _allJokes = [];
  JokeModel? _currentJoke;
  bool _isLoading = true;
  String _error = '';
  bool _showPunchline = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _loadJokes();
  }

  // Carreguem tots els acudits i en mostrem un d'aleatori
  Future<void> _loadJokes() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      _allJokes = await _jokeService.getJokes();
      _pickRandomJoke();
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  // Seleccionar un acudit aleatori de la llista
  void _pickRandomJoke() {
    if (_allJokes.isNotEmpty) {
      setState(() {
        _currentJoke = _allJokes[_random.nextInt(_allJokes.length)];
        _isLoading = false;
        _showPunchline = false;
      });
    }
  }

  // Tornar a cridar al servei i mostrar un nou acudit
  Future<void> _getNewJoke() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Tornem a cridar al servei cada vegada que es prem el botó
      _allJokes = await _jokeService.getJokes();
      _pickRandomJoke();
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acudits Aleatoris 😄'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _buildContent(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _getNewJoke,
        icon: const Icon(Icons.refresh),
        label: const Text('Nou acudit'),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const CircularProgressIndicator();
    }

    if (_error.isNotEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(_error, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadJokes,
            child: const Text('Reintentar'),
          ),
        ],
      );
    }

    if (_currentJoke == null) {
      return const Text('No s\'han trobat acudits');
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.emoji_emotions, size: 64, color: Colors.amber),
        const SizedBox(height: 32),
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Text(
                  _currentJoke!.setup ?? '',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                if (_showPunchline)
                  Text(
                    _currentJoke!.punchline ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  )
                else
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showPunchline = true;
                      });
                    },
                    child: const Text('Veure resposta'),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
