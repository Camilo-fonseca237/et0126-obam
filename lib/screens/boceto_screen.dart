import 'package:flutter/material.dart';

import '../widgets/boceto_painter.dart';

// Pantalla para dibujar con el dedo dónde va el trabajo.
class BocetoScreen extends StatefulWidget {
  final List<Offset?> inicial;

  const BocetoScreen({super.key, required this.inicial});

  @override
  State<BocetoScreen> createState() => _BocetoScreenState();
}

class _BocetoScreenState extends State<BocetoScreen> {
  late List<Offset?> _puntos;

  @override
  void initState() {
    super.initState();
    _puntos = List.of(widget.inicial); // copia para no dañar el original
  }

  // Solo agrega el punto si está dentro del lienzo de 300 x 300.
  void _agregar(Offset punto) {
    if (punto.dx >= 0 && punto.dx <= 300 && punto.dy >= 0 && punto.dy <= 300) {
      setState(() => _puntos.add(punto));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dibuja el boceto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Marca con el dedo dónde va el cuadro, el TV, etc.'),
            const SizedBox(height: 16),
            GestureDetector(
              onPanStart: (d) => _agregar(d.localPosition),
              onPanUpdate: (d) => _agregar(d.localPosition),
              onPanEnd: (_) => setState(() => _puntos.add(null)),
              child: CustomPaint(
                size: const Size(300, 300),
                painter: BocetoPainter(_puntos),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: () => setState(() => _puntos.clear()),
                  icon: const Icon(Icons.delete),
                  label: const Text('Borrar'),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, _puntos),
                  icon: const Icon(Icons.check),
                  label: const Text('Usar boceto'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
