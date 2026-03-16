import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'car_provider.dart';
import 'screens/home_screen.dart';
import 'screens/cars_list_screen.dart';
import 'screens/jokes_screen.dart';
import 'screens/tmb_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CarProvider()),
      ],
      child: MaterialApp(
        title: 'Pràctica 5d - APIs REST',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/cars': (context) => const CarsListScreen(),
          '/jokes': (context) => const JokesScreen(),
          '/tmb': (context) => const TmbScreen(),
        },
      ),
    );
  }
}
