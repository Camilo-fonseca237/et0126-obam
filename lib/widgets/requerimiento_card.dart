import 'package:flutter/material.dart';

import '../models/requerimiento.dart';

// Sin estado: solo recibe datos y una acción.
class RequerimientoCard extends StatelessWidget {
  final Requerimiento requerimiento;
  final VoidCallback onTap;

  const RequerimientoCard({
    super.key,
    required this.requerimiento,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    if (requerimiento.estado == estadoContraoferta) {
      color = Colors.orange;
    } else if (requerimiento.estado == estadoAceptado) {
      color = Colors.green;
    }

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.handyman),
        title: Text(requerimiento.titulo),
        subtitle: Text(
          '${requerimiento.categoria} · ${formatearPrecio(requerimiento.precioFinal())}',
        ),
        trailing: Text(
          requerimiento.estado,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
