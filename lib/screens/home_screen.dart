import 'package:flutter/material.dart';

import '../models/requerimiento.dart';
import '../services/requerimiento_service.dart';
import '../widgets/requerimiento_card.dart';
import 'crear_screen.dart';
import 'detalle_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _servicio = RequerimientoService();
  List<Requerimiento> _requerimientos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final datos = await _servicio.cargar();
    if (!mounted) return;
    setState(() {
      _requerimientos = datos;
      _cargando = false;
    });
  }

  // Abre el formulario y espera el requerimiento creado.
  Future<void> _abrirCrear() async {
    final nuevo = await Navigator.push<Requerimiento>(
      context,
      MaterialPageRoute(builder: (_) => const CrearScreen()),
    );
    if (nuevo == null) return; // el usuario volvió sin publicar

    setState(() => _requerimientos.insert(0, nuevo));
    await _servicio.guardar(_requerimientos);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Trabajo publicado! Espera ofertas.')),
    );
  }

  // Abre el detalle; al volver guarda los cambios (contraoferta, aceptar...).
  Future<void> _abrirDetalle(Requerimiento r) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetalleScreen(requerimiento: r)),
    );
    setState(() {});
    await _servicio.guardar(_requerimientos);
  }

  @override
  Widget build(BuildContext context) {
    final resumen = _servicio.contarPorEstado(_requerimientos);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OBAM'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Image.asset('assets/images/logo_obam.png', width: 80),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Obrero a la mano',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text('Publica el trabajo de tu casa, ofrece tu precio '
                        'y recibe contraofertas de obreros.'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _abrirCrear,
              icon: const Icon(Icons.add),
              label: const Text('Publicar trabajo'),
            ),
          ),
          const SizedBox(height: 16),
          // Resumen construido con el Map del servicio
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final estado in resumen.keys)
                Column(
                  children: [
                    Text(
                      '${resumen[estado]}',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(estado),
                  ],
                ),
            ],
          ),
          const Divider(height: 32),
          const Text(
            'Mis trabajos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (_cargando) const Center(child: CircularProgressIndicator()),
          if (!_cargando && _requerimientos.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Todavía no has publicado trabajos.\n'
                'Toca "Publicar trabajo" para empezar.',
                textAlign: TextAlign.center,
              ),
            ),
          for (final r in _requerimientos)
            RequerimientoCard(
              requerimiento: r,
              onTap: () => _abrirDetalle(r),
            ),
        ],
      ),
    );
  }
}
