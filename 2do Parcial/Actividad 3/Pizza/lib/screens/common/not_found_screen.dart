import 'package:flutter/material.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ruta no encontrada')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 72, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Ruta no encontrada', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () =>
                  Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
              child: const Text('Volver al menú'),
            ),
          ],
        ),
      ),
    );
  }
}