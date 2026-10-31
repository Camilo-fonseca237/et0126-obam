import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

import '../models/obrero.dart';
import '../models/requerimiento.dart';
import '../services/obrero_service.dart';
import '../widgets/obrero_card.dart';

// Nombre: obligatorio y mínimo 3 letras.
final nombreValidator = MultiValidator([
  RequiredValidator(errorText: 'Escribe el nombre del obrero.'),
  MinLengthValidator(3, errorText: 'Usa al menos 3 letras.'),
]);

// Teléfono: obligatorio y debe ser un celular de Colombia (10 números, empieza por 3).
final telefonoValidator = MultiValidator([
  RequiredValidator(errorText: 'Escribe el celular.'),
  PatternValidator(r'^3[0-9]{9}$',
      errorText: 'Debe ser un celular de 10 números que empiece por 3.'),
]);

class ObrerosScreen extends StatefulWidget {
  const ObrerosScreen({super.key});

  @override
  State<ObrerosScreen> createState() => _ObrerosScreenState();
}

class _ObrerosScreenState extends State<ObrerosScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _servicio = ObreroService();
  String? _oficio;
  List<Obrero> _obreros = [];
  bool _cargando = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    final datos = await _servicio.listar();
    if (!mounted) return;
    setState(() {
      _obreros = datos;
      _cargando = false;
    });
  }

  Future<void> _guardar() async {
    // 1 y 2. Si el formulario tiene errores, no se llama al servicio.
    if (!_formKey.currentState!.validate()) return;

    // 3. Se bloquea el botón para no guardar dos veces.
    setState(() => _guardando = true);

    final nuevo = Obrero(
      nombre: _nombreController.text.trim(),
      oficio: _oficio!,
      telefono: _telefonoController.text.trim(),
    );

    try {
      // 4. Espera la respuesta del servicio.
      await _servicio.crear(nuevo);
      final datos = await _servicio.listar();
      if (!mounted) return;
      // 5. Éxito: lista actualizada, mensaje y formulario limpio.
      setState(() {
        _obreros = datos;
        _oficio = null;
      });
      _nombreController.clear();
      _telefonoController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Obrero guardado.')),
      );
    } on StateError catch (error) {
      if (!mounted) return;
      // 6. Error: se deja lo escrito y se muestra el mensaje.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      // 7. Siempre se termina la carga.
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis obreros de confianza')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del obrero',
                    border: OutlineInputBorder(),
                  ),
                  validator: nombreValidator.call,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _oficio,
                  decoration: const InputDecoration(
                    labelText: 'Oficio',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final c in categorias)
                      DropdownMenuItem(value: c, child: Text(c)),
                  ],
                  onChanged: (valor) => setState(() => _oficio = valor),
                  // Regla del dominio: todo obrero debe tener un oficio.
                  validator: (valor) =>
                      valor == null ? 'Elige en qué trabaja el obrero.' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _telefonoController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Celular',
                    border: OutlineInputBorder(),
                  ),
                  validator: telefonoValidator.call,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    // null = botón desactivado mientras se guarda.
                    onPressed: _guardando ? null : _guardar,
                    child: _guardando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Guardar obrero'),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 32),
          if (_cargando) const Center(child: CircularProgressIndicator()),
          if (!_cargando && _obreros.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Todavía no tienes obreros guardados.\n'
                'Llena el formulario de arriba para agregar el primero.',
                textAlign: TextAlign.center,
              ),
            ),
          for (final o in _obreros) ObreroCard(obrero: o),
        ],
      ),
    );
  }
}
