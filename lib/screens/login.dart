import 'package:flutter/material.dart';
// Asegúrate de que este import apunte a tu ApiAuthService
import 'package:tpv_elyella/services/auth_service.dart'; // O 'auth_service.dart' si es Firebase

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Usando tu ApiAuthService
      await AuthService.login(email, password);
      // Si usaras el de Firebase: await AuthService.login(email: email, password: password);

      // Si llegamos aquí, el login fue exitoso y el token se guardó.
      // Navegamos a la pantalla principal (reemplazando el stack de navegación)
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      if (!mounted) return;
      // El mensaje de error viene directamente de la excepción lanzada en el servicio
      final msg = e.toString().replaceFirst(
        'Exception: ',
        '',
      ); // Limpia el prefijo 'Exception: '
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg, style: const TextStyle(color: Colors.white)),
          backgroundColor: Theme.of(
            context,
          ).colorScheme.error, // Color de error
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No necesitamos AppBar para una pantalla de login de este estilo
      // appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0), // Más padding general
          child: ConstrainedBox(
            // Para limitar el ancho del Card en pantallas grandes
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              // Card Theme ya definido en main.dart
              child: Padding(
                padding: const EdgeInsets.all(
                  24.0,
                ), // Más padding dentro del Card
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Título de la aplicación
                      Text(
                        'TPV El y Ella',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(
                                context,
                              ).primaryColor, // Color principal
                            ),
                      ),
                      const SizedBox(height: 8),
                      // Subtítulo
                      Text(
                        'Accede a tu módulo de ventas',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 32), // Espacio más grande

                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          hintText: 'ejemplo@tienda.com',
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Por favor, ingresa tu correo';
                          }
                          // Regex simple para validar email
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                            return 'Formato de correo inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16), // Espacio entre campos

                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                          hintText: 'Ingresa tu contraseña',
                          prefixIcon: Icon(Icons.lock),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Por favor, ingresa tu contraseña';
                          }
                          if (v.length < 6) {
                            // Mínimo de 6 caracteres es más común
                            return 'La contraseña debe tener al menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 32,
                      ), // Espacio más grande antes del botón

                      SizedBox(
                        width: double
                            .infinity, // El botón ocupa todo el ancho disponible
                        child: ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          // El estilo del botón ya está definido en ThemeData
                          child: _loading
                              ? const SizedBox(
                                  height:
                                      24, // Aumenta el tamaño del CircularProgressIndicator
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5, // Grosor del progreso
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Iniciar sesión'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
