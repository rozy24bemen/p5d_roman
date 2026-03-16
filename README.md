# Pràctica 5d: APIs i Serveis REST

## Descripció
Aplicació Flutter que treballa amb APIs REST. Conté 4 exercicis que demostren la connexió a serveis web, la deserialització de JSON, l'ús de Provider per a la gestió d'estat i la integració amb múltiples endpoints.

---

## Exercici 1: Accés a un servei (Car Data API)

### Passos seguits:

1. **Connectar-se al servei**: Ens registrem a [RapidAPI - Car Data](https://rapidapi.com/principalapis/api/car-data) amb el correu de l'escola.
2. **Provar l'endpoint**: Fem click a l'endpoint "Cars" i premem "Test Endpoint" per veure el format del JSON retornat.
3. **Provar amb Postman**: Instal·lem el plugin de Postman al VS Code i configurem una petició GET a `https://car-data.p.rapidapi.com/cars?limit=10` amb les capçaleres `X-RapidAPI-Key` i `X-RapidAPI-Host`.
4. **Analitzar el JSON**: Observem que el JSON retornat té l'estructura:
   ```json
   [{"id": 1, "year": 2020, "make": "Toyota", "model": "Camry", "type": "Sedan"}, ...]
   ```
5. **Crear la classe CarsModel** (`lib/cars_model.dart`): Creem la classe amb els camps `id`, `year`, `make`, `model` i `type`. Afegim el mètode `fromJson()` per crear objectes des d'un Map, i `toJson()` per convertir objectes a Map.
6. **Afegir funcions de conversió JSON**: Afegim les funcions `carsModelFromJson()` per convertir cadenes JSON a llistes de `CarsModel` i `carsModelToJson()` per fer la conversió inversa. Utilitzem `dart:convert` per a la codificació/decodificació.
7. **Afegir dependències**: Afegim el paquet `http: ^1.2.1` al `pubspec.yaml` i executem `flutter pub get`.
8. **Crear l'embolcall del servei** (`lib/httpCarService.dart`): Creem la classe `HttpCarService` que gestiona la URL, la clau API i les capçaleres HTTP internament. Exposem un únic mètode `getCars()` que retorna una `Future<List<CarsModel>>`.
9. **Permetre connexió a Internet**: Afegim `<uses-permission android:name="android.permission.INTERNET"/>` al fitxer `android/app/src/main/AndroidManifest.xml`.
10. **Crear el test unitari** (`test/car_service_test.dart`): Creem un grup de tests que comproven:
    - Que `fromJson` crea objectes correctament
    - Que `toJson` retorna un Map correcte
    - Que `carsModelFromJson` converteix cadenes JSON a llistes
    - Test d'integració que crida al servei real i comprova les dades

### Fragments de codi importants:

**Model CarsModel (lib/cars_model.dart)**:
```dart
class CarsModel {
  final int? id;
  final int? year;
  final String? make;
  final String? model;
  final String? type;

  CarsModel({this.id, this.year, this.make, this.model, this.type});

  factory CarsModel.fromJson(Map<String, dynamic> json) {
    return CarsModel(
      id: json['id'] as int?,
      year: json['year'] as int?,
      make: json['make'] as String?,
      model: json['model'] as String?,
      type: json['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'year': year, 'make': make, 'model': model, 'type': type};
  }
}
```
`fromJson` rep un Map (JSON decodificat) i crea un objecte. `toJson` fa la conversió inversa.

**Servei HttpCarService (lib/httpCarService.dart)**:
```dart
Future<List<CarsModel>> getCars({int limit = 10}) async {
  final uri = Uri.parse('$_endpoint?limit=$limit');
  final response = await http.get(uri, headers: {
    'X-RapidAPI-Key': _key,
    'X-RapidAPI-Host': _host,
  });
  if (response.statusCode == 200) {
    return carsModelFromJson(response.body);
  } else {
    throw Exception('Error al carregar cotxes: ${response.statusCode}');
  }
}
```
Fa una petició GET amb les capçaleres necessàries. Si el codi de resposta és 200, decodifica el JSON. Si no, llança una excepció.

### Preguntes:

**1. Què és una API REST?**
Una API REST (Representational State Transfer) és una interfície de programació d'aplicacions que segueix els principis de l'arquitectura REST. Utilitza els mètodes HTTP estàndard (GET, POST, PUT, DELETE) per accedir i manipular recursos identificats per URLs (endpoints). Les dades s'intercanvien normalment en format JSON.

**2. Què és la serialització/deserialització?**
La serialització és el procés de convertir un objecte en memòria a un format que es pugui transmetre o emmagatzemar (com JSON o XML). La deserialització és el procés invers: convertir dades en format JSON/XML a objectes del nostre programa. A Flutter, fem servir `json.decode()` per deserialitzar i `json.encode()` per serialitzar.

**3. Què són les capçaleres HTTP?**
Les capçaleres HTTP (headers) són metadades que s'envien juntament amb les peticions i respostes HTTP. Contenen informació com el tipus de contingut, l'autenticació, la codificació, etc. En el nostre cas, les capçaleres `X-RapidAPI-Key` i `X-RapidAPI-Host` s'utilitzen per autenticar-nos contra el servei de RapidAPI.

---

## Exercici 2: Integrar vista i model (Provider + ListView)

### Passos seguits:

1. **Afegir dependència Provider**: Afegim `provider: ^6.1.2` al `pubspec.yaml` i executem `flutter pub get`.
2. **Crear el CarProvider** (`lib/car_provider.dart`): Creem una classe que estén `ChangeNotifier` amb els atributs `_cars` (llista de cotxes), `_isLoading` (indicador de càrrega) i `_error` (missatge d'error). El mètode `loadCars()` crida al servei i notifica als listeners.
3. **Configurar el Provider a main.dart**: Embolcallem el `MaterialApp` amb un `MultiProvider` que proporciona el `CarProvider` a tota l'aplicació.
4. **Crear la pantalla CarsListScreen** (`lib/screens/cars_list_screen.dart`): Utilitzem `Consumer<CarProvider>` per escoltar els canvis d'estat. Mostrem un `CircularProgressIndicator` durant la càrrega, un missatge d'error si falla, i un `ListView.builder` amb la llista de cotxes.
5. **Implementar la navegació**: Creem una pantalla principal (`HomeScreen`) amb botons per navegar als diferents exercicis.

### Fragments de codi importants:

**CarProvider (lib/car_provider.dart)**:
```dart
class CarProvider extends ChangeNotifier {
  List<CarsModel> _cars = [];
  bool _isLoading = false;
  String _error = '';

  Future<void> loadCars() async {
    _isLoading = true;
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
```
El Provider encapsula l'estat (llista de cotxes, càrrega, error). Quan canvia l'estat, `notifyListeners()` avisa als widgets que estan escoltant.

**ListView a CarsListScreen**:
```dart
Consumer<CarProvider>(
  builder: (context, carProvider, child) {
    return ListView.builder(
      itemCount: carProvider.cars.length,
      itemBuilder: (context, index) {
        final car = carProvider.cars[index];
        return ListTile(
          title: Text('${car.make} ${car.model}'),
          subtitle: Text('Any: ${car.year} - Tipus: ${car.type}'),
        );
      },
    );
  },
)
```
`Consumer` reconstrueix el widget quan el Provider notifica canvis. `ListView.builder` crea els elements de la llista de forma eficient (lazy loading).

---

## Exercici 3: Acudits (Jokes API)

### Passos seguits:

1. **Provar l'API**: Accedim a `https://api.sampleapis.com/jokes/goodJokes` des del navegador o Postman per veure el format JSON:
   ```json
   [{"id": 1, "setup": "Why don't scientists...", "punchline": "Because they..."}, ...]
   ```
2. **Crear el model JokeModel** (`lib/joke_model.dart`): Creem la classe amb els camps `id`, `setup` (la pregunta) i `punchline` (la resposta). Afegim `fromJson`, `toJson` i una funció de conversió de llista.
3. **Crear el servei JokeService** (`lib/joke_service.dart`): Creem la classe amb el mètode `getJokes()` que fa una petició GET a l'API (sense necessitat de clau d'autenticació).
4. **Crear la pantalla JokesScreen** (`lib/screens/jokes_screen.dart`): Implementem una pantalla que:
   - Carrega tots els acudits al iniciar
   - Mostra un acudit aleatori
   - Té un botó "Veure resposta" per mostrar el punchline
   - Té un FloatingActionButton per cridar al servei de nou i mostrar un nou acudit aleatori
5. **Separació MVC**: El Model és `JokeModel`, el Controlador és `JokeService`, i la Vista és `JokesScreen`.

### Fragments de codi importants:

**Model JokeModel (lib/joke_model.dart)**:
```dart
class JokeModel {
  final int? id;
  final String? setup;
  final String? punchline;

  factory JokeModel.fromJson(Map<String, dynamic> json) {
    return JokeModel(
      id: json['id'] as int?,
      setup: json['setup'] as String?,
      punchline: json['punchline'] as String?,
    );
  }
}
```

**Servei JokeService (lib/joke_service.dart)**:
```dart
class JokeService {
  final String _endpoint = 'https://api.sampleapis.com/jokes/goodJokes';

  Future<List<JokeModel>> getJokes() async {
    final response = await http.get(Uri.parse(_endpoint));
    if (response.statusCode == 200) {
      return jokeModelFromJson(response.body);
    } else {
      throw Exception('Error al carregar acudits: ${response.statusCode}');
    }
  }
}
```
Aquesta API és pública i no requereix clau d'autenticació. Retorna una llista JSON d'acudits.

**Selecció d'acudit aleatori a JokesScreen**:
```dart
void _pickRandomJoke() {
  if (_allJokes.isNotEmpty) {
    setState(() {
      _currentJoke = _allJokes[_random.nextInt(_allJokes.length)];
      _showPunchline = false;
    });
  }
}
```
Cada vegada que es prem el botó, es torna a cridar al servei i es selecciona un acudit aleatori de la llista.

---

## Exercici 4: TMB Barcelona

### Passos seguits:

1. **Registrar-se a TMB**: Accedim a [developer.tmb.cat](https://developer.tmb.cat/) i ens registrem per obtenir un `app_id` i un `app_key`.

2. **Consultar la documentació**: Revisem la documentació de l'API a [developer.tmb.cat/api-docs/v1](https://developer.tmb.cat/api-docs/v1).
3. **Provar amb Postman**: Configurem i provem els 3 endpoints:
   - **Endpoint 1 - Línies de bus**: `GET https://api.tmb.cat/v1/transit/linies/bus?app_id=XXX&app_key=YYY`
   - **Endpoint 2 - Info d'una parada**: `GET https://api.tmb.cat/v1/transit/parades/{codiParada}?app_id=XXX&app_key=YYY`
   - **Endpoint 3 - iBus (temps real)**: `GET https://api.tmb.cat/v1/ibus/stops/{codiParada}?app_id=XXX&app_key=YYY`
4. **Crear els models** (`lib/tmb_model.dart`): Creem les classes `TmbLine` (línia de bus), `TmbStop` (parada) i `TmbIBus` (temps d'espera en temps real).
5. **Crear el servei TmbService** (`lib/tmb_service.dart`): Creem la classe amb 3 mètodes: `getBusLines()`, `getStop(code)` i `getIBus(code)`.
6. **Crear la pantalla TmbScreen** (`lib/screens/tmb_screen.dart`): Implementem una pantalla amb 2 pestanyes (TabBar):
   - **Pestanya "Línies"**: Mostra totes les línies de bus amb el seu codi, nom, origen i destí.
   - **Pestanya "iBus Parada"**: Permet introduir un codi de parada i mostra la informació de la parada i els busos que han de passar amb el temps d'espera en temps real.

### Fragments de codi importants:

**Model TmbIBus (lib/tmb_model.dart)**:
```dart
class TmbIBus {
  final String? line;
  final String? destination;
  final int? timeInMin;

  factory TmbIBus.fromJson(Map<String, dynamic> json) {
    return TmbIBus(
      line: json['line']?.toString(),
      destination: json['text-ca']?.toString(),
      timeInMin: json['t-in-min'] as int?,
    );
  }
}
```
L'API iBus retorna la línia, la destinació en català (`text-ca`), i el temps en minuts (`t-in-min`).

**Servei TmbService - getIBus (lib/tmb_service.dart)**:
```dart
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
```
L'autenticació es fa via paràmetres de query (`app_id` i `app_key`).

**Consulta simultània de parada i iBus**:
```dart
final results = await Future.wait([
  _tmbService.getStop(code),
  _tmbService.getIBus(code),
]);
```
Fem les dues crides simultàniament amb `Future.wait` per millorar el rendiment.

---

## Estructura del projecte

```
lib/
├── main.dart                  # App principal amb Provider i navegació
├── cars_model.dart            # Model CarsModel (Exercici 1)
├── httpCarService.dart        # Servei Car Data API (Exercici 1)
├── car_provider.dart          # Provider de cotxes (Exercici 2)
├── joke_model.dart            # Model JokeModel (Exercici 3)
├── joke_service.dart          # Servei Jokes API (Exercici 3)
├── tmb_model.dart             # Models TMB (Exercici 4)
├── tmb_service.dart           # Servei TMB API (Exercici 4)
└── screens/
    ├── home_screen.dart       # Pantalla principal amb navegació
    ├── cars_list_screen.dart  # ListView de cotxes (Exercici 2)
    ├── jokes_screen.dart      # Pantalla d'acudits (Exercici 3)
    └── tmb_screen.dart        # Pantalla TMB (Exercici 4)
test/
├── car_service_test.dart      # Tests del servei de cotxes (Exercici 1)
└── widget_test.dart           # Test bàsic del widget
```

## Com executar

1. Clona el repositori: `git clone https://github.com/rozy24bemen/p5d.git`
2. Instal·la les dependències: `flutter pub get`
3. Substitueix les claus API als fitxers de servei:
   - `lib/httpCarService.dart`: Substitueix `YOUR_RAPIDAPI_KEY` per la teva clau de RapidAPI
   - `lib/tmb_service.dart`: Substitueix `YOUR_TMB_APP_ID` i `YOUR_TMB_APP_KEY` per les teves credencials de TMB
4. Executa l'aplicació: `flutter run`
5. Executa els tests: `flutter test`

## Dependències

- `http: ^1.2.1` - Per fer peticions HTTP als serveis web
- `provider: ^6.1.2` - Per a la gestió d'estat amb el patró Provider
- `cupertino_icons: ^1.0.8` - Icones d'estil iOS
