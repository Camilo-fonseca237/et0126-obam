import 'package:flutter/material.dart';

import '../models/requerimiento.dart';
import '../widgets/boceto_painter.dart';

class DetalleScreen extends StatefulWidget {
  final Requerimiento requerimiento;

  const DetalleScreen({super.key, required this.requerimiento});

  @override
  State<DetalleScreen> createState() => _DetalleScreenState();
}

class _DetalleScreenState extends State<DetalleScreen> {
  late int _propuesta; // precio que el obrero va a contraofertar

  @override
  void initState() {
    super.initState();
    _propuesta = widget.requerimiento.precioFinal();
  }

  void _subir() => setState(() => _propuesta += 5000);

  void _bajar() {
    if (_propuesta > 5000) {
      setState(() => _propuesta -= 5000);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.requerimiento;

    return Scaffold(
      appBar: AppBar(title: Text(r.titulo)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('${r.categoria} · ${r.estado}',
              style: const TextStyle(fontSize: 16)),
          if (r.descripcion != null) ...[
            const SizedBox(height: 8),
            Text(r.descripcion!),
          ],
          const SizedBox(height: 16),
          Center(
            child: CustomPaint(
              size: const Size(300, 300),
              painter: BocetoPainter(r.boceto),
            ),
          ),
          const SizedBox(height: 16),
          Text('El cliente ofrece: ${formatearPrecio(r.precioOfrecido)}',
              style: const TextStyle(fontSize: 18)),
          if (r.contraoferta != null)
            Text('Contraoferta del obrero: ${formatearPrecio(r.contraoferta!)}',
                style: const TextStyle(fontSize: 18, color: Colors.orange)),
          const Divider(height: 32),

          // Simulación: el obrero propone otro precio
          if (r.estado != estadoAceptado) ...[
            const Text('Modo obrero (simulación)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _bajar,
                  icon: const Icon(Icons.remove_circle),
                ),
                Text(formatearPrecio(_propuesta),
                    style: const TextStyle(fontSize: 22)),
                IconButton(
                  onPressed: _subir,
                  icon: const Icon(Icons.add_circle),
                ),
              ],
            ),
            OutlinedButton(
              onPressed: () => setState(() => r.contraofertar(_propuesta)),
              child: const Text('Enviar contraoferta'),
            ),
          ],

          // El usuario decide sobre la contraoferta
          if (r.estado == estadoContraoferta) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => setState(() => r.aceptar()),
                  child: const Text('Aceptar'),
                ),
                OutlinedButton(
                  onPressed: () => setState(() => r.rechazar()),
                  child: const Text('Rechazar'),
                ),
              ],
            ),
          ],

          if (r.estado == estadoAceptado)
            Card(
              color: Colors.green.shade100,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '¡Trato hecho! El trabajo se hará por '
                  '${formatearPrecio(r.precioFinal())}.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
