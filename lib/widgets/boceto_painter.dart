import 'package:flutter/material.dart';

// Canvas: dibuja el boceto del trabajo con los puntos guardados.
class BocetoPainter extends CustomPainter {
  final List<Offset?> puntos;

  BocetoPainter(this.puntos);

  @override
  void paint(Canvas canvas, Size size) {
    // Fondo tipo pared
    final fondo = Paint();
    fondo.color = const Color(0xFFF5F0E6);
    canvas.drawRect(Offset.zero & size, fondo);

    // Lápiz con el que se dibujan las líneas
    final lapiz = Paint();
    lapiz.color = Colors.brown;
    lapiz.strokeWidth = 4;
    lapiz.strokeCap = StrokeCap.round;

    // Une cada punto con el siguiente, salvo cuando hay un null (corte).
    for (int i = 0; i < puntos.length - 1; i++) {
      final actual = puntos[i];
      final siguiente = puntos[i + 1];
      if (actual != null && siguiente != null) {
        canvas.drawLine(actual, siguiente, lapiz);
      }
    }
  }

  @override
  bool shouldRepaint(BocetoPainter oldDelegate) => true;
}
