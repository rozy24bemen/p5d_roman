import 'package:flutter/material.dart';
import '../tmb_model.dart';
import '../tmb_service.dart';

// Pantalla principal de TMB (Exercici 4)
// Permet consultar línies de bus, parades i temps d'espera en temps real
class TmbScreen extends StatefulWidget {
  const TmbScreen({super.key});

  @override
  State<TmbScreen> createState() => _TmbScreenState();
}

class _TmbScreenState extends State<TmbScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TmbService _tmbService = TmbService();

  // Estat per a línies de bus
  List<TmbLine> _busLines = [];
  bool _loadingLines = false;
  String _errorLines = '';

  // Estat per a la consulta de parades (iBus)
  final TextEditingController _stopCodeController = TextEditingController();
  List<TmbStop> _stopInfo = [];
  List<TmbIBus> _iBusData = [];
  bool _loadingIBus = false;
  String _errorIBus = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _stopCodeController.dispose();
    super.dispose();
  }

  // Carregar línies de bus (Endpoint 1)
  Future<void> _loadBusLines() async {
    setState(() {
      _loadingLines = true;
      _errorLines = '';
    });

    try {
      _busLines = await _tmbService.getBusLines();
    } catch (e) {
      _errorLines = 'Error: $e';
    }

    setState(() {
      _loadingLines = false;
    });
  }

  // Consultar parada i iBus (Endpoints 2 i 3)
  Future<void> _searchStop() async {
    final code = _stopCodeController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _loadingIBus = true;
      _errorIBus = '';
      _stopInfo = [];
      _iBusData = [];
    });

    try {
      // Crida als endpoints 2 i 3 simultàniament
      final results = await Future.wait([
        _tmbService.getStop(code),
        _tmbService.getIBus(code),
      ]);

      _stopInfo = results[0] as List<TmbStop>;
      _iBusData = results[1] as List<TmbIBus>;
    } catch (e) {
      _errorIBus = 'Error: $e';
    }

    setState(() {
      _loadingIBus = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TMB Barcelona'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.directions_bus), text: 'Línies'),
            Tab(icon: Icon(Icons.access_time), text: 'iBus Parada'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBusLinesTab(),
          _buildIBusTab(),
        ],
      ),
    );
  }

  // Tab de línies de bus
  Widget _buildBusLinesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: ElevatedButton.icon(
            onPressed: _loadingLines ? null : _loadBusLines,
            icon: const Icon(Icons.download),
            label: const Text('Carregar línies de bus'),
          ),
        ),
        if (_loadingLines) const CircularProgressIndicator(),
        if (_errorLines.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(_errorLines, style: const TextStyle(color: Colors.red)),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: _busLines.length,
            itemBuilder: (context, index) {
              final line = _busLines[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _parseColor(line.color),
                    child: Text(
                      line.code ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  title: Text(line.name ?? 'Línia desconeguda'),
                  subtitle: Text(
                    '${line.origin ?? ''} → ${line.destination ?? ''}',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Tab de consulta iBus per parada
  Widget _buildIBusTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _stopCodeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Codi de parada',
                    hintText: 'Ex: 1265',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.pin_drop),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _loadingIBus ? null : _searchStop,
                child: const Text('Cercar'),
              ),
            ],
          ),
        ),
        if (_loadingIBus) const CircularProgressIndicator(),
        if (_errorIBus.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(_errorIBus, style: const TextStyle(color: Colors.red)),
          ),
        // Informació de la parada
        if (_stopInfo.isNotEmpty)
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: Colors.blue[50],
            child: ListTile(
              leading: const Icon(Icons.location_on, color: Colors.blue),
              title: Text(_stopInfo.first.name ?? 'Parada'),
              subtitle: Text(
                '${_stopInfo.first.address ?? ''}\n${_stopInfo.first.municipality ?? ''}',
              ),
            ),
          ),
        const SizedBox(height: 8),
        // Llista de busos en temps real
        if (_iBusData.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: const [
                Icon(Icons.access_time, size: 16),
                SizedBox(width: 4),
                Text(
                  'Pròxims busos:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
        Expanded(
          child: _iBusData.isEmpty && !_loadingIBus && _errorIBus.isEmpty
              ? const Center(
                  child: Text(
                    'Introdueix un codi de parada per veure\nels busos en temps real',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  itemCount: _iBusData.length,
                  itemBuilder: (context, index) {
                    final bus = _iBusData[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red,
                          child: Text(
                            bus.line ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(bus.destination ?? 'Destí desconegut'),
                        trailing: Text(
                          '${bus.timeInMin ?? '?'} min',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Convertir color hex string a Color
  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.grey;
    try {
      final cleaned = hex.replaceAll('#', '');
      return Color(int.parse('FF$cleaned', radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }
}
