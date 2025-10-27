import 'package:flutter/material.dart';
import 'package:tpv_elyella/screens/login.dart';
import 'package:tpv_elyella/screens/productoScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'tpv_elyella',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // Arrancamos la app en la pantalla de login (PWA-friendly)
      home: const LoginScreen(),
      routes: {
        '/home': (context) => const MyHomePage(title: 'Home'),
        '/productos': (context) => const ProductoScreen(),
      },
    );
  }
}

// Página de ejemplo que ya existía. La conservamos como destino posterior al login.
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Bienvenido al TPV'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/productos'),
              icon: const Icon(Icons.inventory_2),
              label: const Text('Ver Productos'),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
