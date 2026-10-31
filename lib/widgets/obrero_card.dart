import 'package:flutter/material.dart';

import '../models/obrero.dart';

// Sin estado: solo muestra los datos de un obrero.
class ObreroCard extends StatelessWidget {
  final Obrero obrero;

  const ObreroCard({super.key, required this.obrero});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.person),
        title: Text(obrero.nombre),
        subtitle: Text('${obrero.oficio} · ${obrero.telefono}'),
      ),
    );
  }
}
