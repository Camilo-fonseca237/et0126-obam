import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/requerimiento.dart';

class RequerimientoService {
  static const String _llave = 'requerimientos';

  // Lee la lista guardada en el teléfono.
  Future<List<Requerimiento>> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final String? texto = prefs.getString(_llave);
    if (texto == null) return [];

    final List datos = jsonDecode(texto);
    final List<Requerimiento> lista = [];
    for (final item in datos) {
      lista.add(Requerimiento.fromMap(item));
    }
    return lista;
  }

  // Guarda toda la lista como texto JSON.
  Future<void> guardar(List<Requerimiento> lista) async {
    final prefs = await SharedPreferences.getInstance();
    final datos = lista.map((r) => r.toMap()).toList();
    await prefs.setString(_llave, jsonEncode(datos));
  }

  // Map: cuántos requerimientos hay en cada estado.
  Map<String, int> contarPorEstado(List<Requerimiento> lista) {
    final Map<String, int> resumen = {
      estadoPublicado: 0,
      estadoContraoferta: 0,
      estadoAceptado: 0,
    };
    for (final r in lista) {
      resumen[r.estado] = resumen[r.estado]! + 1;
    }
    return resumen;
  }
}
