import 'package:flutter/material.dart';

import '../models/requerimiento.dart';
import '../widgets/boceto_painter.dart';
import 'boceto_screen.dart';

// Función de validación separada: el precio debe ser un número >= 10.000.
String? validarPrecio(String? texto) {
  if (texto == null || texto.trim().isEmpty) {
    return 'Escribe cuánto ofreces';
  }
  final int? valor = int.tryParse(texto.trim());
  if (valor == null) {
    return 'Usa solo números, sin puntos';
  }
  if (valor < 10000) {
    return 'La oferta mínima es \$ 10.000';
  }
  return null;
}

class CrearScreen extends StatefulWidget {
  const CrearScreen({super.key});

  @override
  State<CrearScreen> createState() => _CrearScreenState();
}

class _CrearScreenState extends State<CrearScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();
  String? _categoria;
  List<Offset?> _boceto = [];

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  Future<void> _dibujar() async {
    final puntos = await Navigator.push<List<Offset?>>(
      context,
      MaterialPageRoute(builder: (_) => BocetoScreen(inicial: _boceto)),
    );
    if (puntos != null) {
      setState(() => _boceto = puntos);
    }
  }

  void _publicar() {
    if (!_formKey.currentState!.validate()) return;
    if (_boceto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dibuja un boceto del trabajo')),
      );
      return;
    }

    final descripcion = _descripcionController.text.trim();
    final nuevo = Requerimiento(
      titulo: _tituloController.text.trim(),
      categoria: _categoria!,
      descripcion: descripcion.isEmpty ? null : descripcion,
      precioOfrecido: int.parse(_precioController.text.trim()),
      boceto: _boceto,
    );
    Navigator.pop(context, nuevo); // devuelve el requerimiento al inicio
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo trabajo')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: '¿Qué necesitas?',
                hintText: 'Ej: Colgar 3 cuadros en la sala',
                border: OutlineInputBorder(),
              ),
              validator: (texto) {
                if (texto == null || texto.trim().length < 5) {
                  return 'Describe el trabajo (mínimo 5 letras)';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _categoria,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final c in categorias)
                  DropdownMenuItem(value: c, child: Text(c)),
              ],
              onChanged: (valor) => setState(() => _categoria = valor),
              validator: (valor) =>
                  valor == null ? 'Elige una categoría' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descripcionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Detalles (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _precioController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Tu oferta en pesos',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              validator: validarPrecio,
            ),
            const SizedBox(height: 16),
            const Text('Boceto del trabajo',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Center(
              child: _boceto.isEmpty
                  ? const Text('Aún no has dibujado nada')
                  : CustomPaint(
                      size: const Size(300, 300),
                      painter: BocetoPainter(_boceto),
                    ),
            ),
            TextButton.icon(
              onPressed: _dibujar,
              icon: const Icon(Icons.brush),
              label: Text(_boceto.isEmpty ? 'Dibujar boceto' : 'Editar boceto'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _publicar,
              child: const Text('Publicar'),
            ),
          ],
        ),
      ),
    );
  }
}
