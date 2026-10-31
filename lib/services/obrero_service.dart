import '../models/obrero.dart';

// Simula una API: la lista vive en memoria y se borra al cerrar la app.
class ObreroService {
  static final List<Obrero> _obreros = [];

  // Devuelve la lista después de una pequeña espera.
  Future<List<Obrero>> listar() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List<Obrero>.unmodifiable(_obreros);
  }

  // Guarda un obrero. Regla: no se puede repetir el teléfono.
  Future<Obrero> crear(Obrero obrero) async {
    await Future.delayed(const Duration(milliseconds: 700));
    for (final actual in _obreros) {
      if (actual.telefono == obrero.telefono) {
        throw StateError('Ya tienes un obrero con ese teléfono.');
      }
    }
    _obreros.insert(0, obrero);
    return obrero;
  }
}
