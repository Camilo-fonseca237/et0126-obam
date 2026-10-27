import 'dart:ui';

// Set: las categorías no se pueden repetir.
const Set<String> categorias = {
  'Colgar cuadros',
  'Instalar TV',
  'Armar muebles',
  'Plomería básica',
  'Electricidad básica',
  'Otro',
};

// Estados posibles de un requerimiento.
const String estadoPublicado = 'Publicado';
const String estadoContraoferta = 'Contraoferta';
const String estadoAceptado = 'Aceptado';

class Requerimiento {
  final String titulo;
  final String categoria;
  final String? descripcion; // puede faltar: es opcional
  final int precioOfrecido;
  final List<Offset?> boceto; // null = el usuario levantó el dedo
  int? contraoferta; // null mientras el obrero no ofrezca
  String estado;

  Requerimiento({
    required this.titulo,
    required this.categoria,
    this.descripcion,
    required this.precioOfrecido,
    required this.boceto,
    this.contraoferta,
    this.estado = estadoPublicado,
  });

  // El obrero propone otro precio.
  void contraofertar(int valor) {
    contraoferta = valor;
    estado = estadoContraoferta;
  }

  // El usuario acepta la contraoferta.
  void aceptar() {
    estado = estadoAceptado;
  }

  // El usuario rechaza: se borra la contraoferta.
  void rechazar() {
    contraoferta = null;
    estado = estadoPublicado;
  }

  // Precio con el que se cerraría el trabajo.
  int precioFinal() {
    return contraoferta ?? precioOfrecido;
  }

  // Convierte el objeto a Map para guardarlo.
  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'categoria': categoria,
      'descripcion': descripcion,
      'precioOfrecido': precioOfrecido,
      'contraoferta': contraoferta,
      'estado': estado,
      'boceto': boceto.map((p) => p == null ? null : [p.dx, p.dy]).toList(),
    };
  }

  // Crea el objeto a partir del Map guardado.
  factory Requerimiento.fromMap(Map<String, dynamic> map) {
    final List puntos = map['boceto'];
    return Requerimiento(
      titulo: map['titulo'],
      categoria: map['categoria'],
      descripcion: map['descripcion'],
      precioOfrecido: map['precioOfrecido'],
      contraoferta: map['contraoferta'],
      estado: map['estado'],
      boceto: puntos
          .map((p) => p == null ? null : Offset(p[0], p[1]))
          .toList(),
    );
  }
}

// while: pone un punto cada tres cifras. 120000 -> $ 120.000
String formatearPrecio(int valor) {
  String texto = valor.toString();
  String resultado = '';
  int cifras = 0;
  int i = texto.length - 1;
  while (i >= 0) {
    if (cifras == 3) {
      resultado = '.$resultado';
      cifras = 0;
    }
    resultado = texto[i] + resultado;
    cifras++;
    i--;
  }
  return '\$ $resultado';
}
