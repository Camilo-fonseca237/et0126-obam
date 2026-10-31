# OBAM · Obrero a la mano

Taller integrador ET0126 · Programación de Dispositivos Móviles · I.U. Pascual Bravo

> Mi app se llama **OBAM (Obrero a la mano)**. Está dirigida a **personas que necesitan arreglos pequeños en su casa**, quienes necesitan **encontrar rápido a alguien para colgar un cuadro o instalar un TV y acordar un precio justo**. La app le ayudará a **publicar el trabajo y negociar el precio con un obrero** mediante **la publicación de requerimientos con boceto, una oferta de precio y las contraofertas del obrero**.

## Propuesta

1. **Nombre:** OBAM, Obrero a la mano.
2. **Usuario:** personas que necesitan arreglos pequeños en casa (colgar cuadros, instalar un TV, armar muebles) y los obreros que hacen esos trabajos.
3. **Problema:** para un trabajo pequeño es difícil conseguir a alguien de confianza y saber cuánto pagar.
4. **Solución:** funciona como InDriver, pero para trabajos de casa. El usuario publica lo que necesita y ofrece un precio; el obrero puede aceptar ese precio o contraofertar.
5. **Funciones iniciales:**
   - Publicar un trabajo con título, categoría, precio ofrecido y un boceto.
   - Ver la lista de mis trabajos con su estado.
   - Recibir una contraoferta del obrero y aceptarla o rechazarla.
6. **Recorrido principal:**
   1. Abro la app y veo mis trabajos y un resumen por estado.
   2. Toco **Publicar trabajo**, lleno el formulario y dibujo el boceto.
   3. Publico; el trabajo aparece en la lista como _Publicado_.
   4. Abro el trabajo; en **Modo obrero** se simula la contraoferta con los botones + y −.
   5. Acepto o rechazo la contraoferta.
7. **Datos:** título, categoría, detalles (opcional), precio ofrecido, contraoferta, estado y los puntos del boceto.
8. **Canvas:** en lugar de una foto, el usuario dibuja con el dedo un boceto de dónde va el trabajo (por ejemplo, la pared y el lugar del TV). El boceto se ve en el detalle para que el obrero entienda qué hay que hacer.

> **Nota:** en esta versión la contraoferta del obrero se simula en el mismo celular. Todavía no hay usuarios ni servidor.

## Estructura

```text
lib/
  main.dart                         MaterialApp y tema
  models/requerimiento.dart         Clase Requerimiento, categorías (Set), formatearPrecio (while)
  services/requerimiento_service.dart  Guardar/cargar con SharedPreferences y resumen (Map)
  screens/home_screen.dart          Inicio: descripción, botón principal, resumen y lista
  screens/crear_screen.dart         Formulario con validación
  screens/boceto_screen.dart        Dibujo con el dedo (Canvas)
  screens/detalle_screen.dart       Detalle, contraoferta, aceptar/rechazar
  widgets/requerimiento_card.dart   Tarjeta sin estado de cada trabajo
  widgets/boceto_painter.dart       CustomPainter que dibuja el boceto
assets/images/logo_obam.png
```

## Almacenamiento: ¿por qué SharedPreferences?

Uso **SharedPreferences** porque la app guarda pocos trabajos y con pocos campos. Convierto la lista a texto JSON (`jsonEncode`) y la guardo con una sola llave. Al abrir la app, la leo y la convierto otra vez en objetos (`jsonDecode` + `requerimientoDesdeMap`). .

## Conceptos de Dart en mi app

| Concepto                             | Dónde                                                                                                                                                                                              |
| ------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Tipos, `final`/`const` y null safety | `models/requerimiento.dart`: `descripcion` y `contraoferta` son nullable porque pueden faltar; el resto no.                                                                                        |
| Clases y objetos                     | Clase `Requerimiento` con constructor y métodos `contraofertar()`, `aceptar()`, `rechazar()` y `precioFinal()`. Se crean objetos en `crear_screen.dart` y al cargar con `requerimientoDesdeMap()`. |
| Funciones                            | `validarPrecio()` en `crear_screen.dart`, `formatearPrecio()` y `requerimientoDesdeMap()` en el modelo.                                                                                            |
| `List`                               | `List<Requerimiento>` en `home_screen.dart` y los puntos del boceto `List<Offset?>`.                                                                                                               |
| `Set`                                | `categorias` en el modelo: una categoría no se puede repetir.                                                                                                                                      |
| `Map`                                | `contarPorEstado()` en el servicio devuelve cuántos trabajos hay por estado. También `toMap()` para guardar.                                                                                       |
| `if` y `for`                         | `if` en las validaciones y en el color del estado de la tarjeta; `for` para recorrer la lista, contar estados y dibujar las líneas del boceto.                                                     |
| `while`                              | `formatearPrecio()`: recorre las cifras del precio de derecha a izquierda y pone un punto cada tres cifras (`120000` → `$ 120.000`). Es finito porque termina al llegar a la primera cifra.        |

## Stateless y Stateful

- **StatelessWidget:** `ObamApp`, `RequerimientoCard` (solo recibe datos y una acción).
- **StatefulWidget:** `HomeScreen` (lista y carga), `CrearScreen` (formulario y boceto), `BocetoScreen` (puntos que se dibujan) y `DetalleScreen` (precio de la contraoferta con + y −).

## Cómo ejecutar

En el repositorio solo están los archivos de clase (`lib`, `assets`, `pubspec.yaml`). Las carpetas de Android y las demás plataformas se generan con `flutter create`:

```bash
git clone https://github.com/Camilo-fonseca237/et0126-obam.git
cd et0126-obam
flutter create . --project-name obam
flutter pub get
flutter run
```

También se puede ejecutar en FlutLab (flutlab.io) subiendo el proyecto.

**Prueba de persistencia:** publica un trabajo, cierra la app por completo y ábrela otra vez. El trabajo y su estado siguen en la lista.

## Ejecución

Probé la app en el emulador Android de Android Studio, pero el emulador mostraba la pantalla deformada, así que terminé de probarla en FlutLab. El código es el mismo para Android.

## Capturas

| Inicio                         | Validación                             | Contraoferta                     |
| ------------------------------ | -------------------------------------- | -------------------------------- |
| ![Inicio](capturas/inicio.png) | ![Formulario](capturas/formulario.png) | ![Detalle](capturas/detalle.png) |

## Uso de IA

Profe usé Claude como apoyo para estructurar el proyecto, generar una base primera versión del código, simplificarlo a lo visto en clase y resolver errores de configuración del entorno. Revisé y probé cada parte, y puedo explicar y modificar cualquier archivo.

---

# Taller de continuación: formularios y servicio en memoria

> Esta parte es del segundo taller. Todo lo anterior (publicar trabajos, boceto, contraoferta y SharedPreferences) sigue igual.

## Propósito del flujo

Agregué la pantalla **Mis obreros de confianza**, que se abre desde el botón del mismo nombre en el inicio. Sirve para que el usuario guarde los obreros que ya le hicieron un buen trabajo (nombre, oficio y celular) y así poder llamarlos otra vez para el próximo arreglo de la casa.

## Archivos nuevos

```text
lib/
  models/obrero.dart          Clase Obrero (nombre, oficio, telefono)
  services/obrero_service.dart  listar() y crear() con Future.delayed, lista en memoria
  screens/obreros_screen.dart  Formulario + lista de obreros (StatefulWidget)
  widgets/obrero_card.dart     Tarjeta de un obrero (StatelessWidget)
```

En `home_screen.dart` solo se agregó el botón para abrir la pantalla nueva.

## Campos y validaciones

Se usa la librería `form_field_validator` (`flutter pub add form_field_validator`).

| Campo | Control | Validación |
| --- | --- | --- |
| Nombre del obrero | Texto | `MultiValidator` con `RequiredValidator` y `MinLengthValidator(3)`. |
| Oficio | Lista desplegable (las mismas categorías de los trabajos) | Regla del dominio: todo obrero debe tener un oficio. |
| Celular | Texto (teclado de teléfono) | `MultiValidator` con `RequiredValidator` y `PatternValidator`: 10 números y empieza por 3 (celular de Colombia). |

El botón **Guardar obrero** ejecuta `_formKey.currentState!.validate()`. Si hay errores, se muestran en los campos y no se llama al servicio.

## Modelo y servicio

- **Modelo:** `Obrero` es una clase con tres campos de tipo `String`.
- **Servicio:** `ObreroService` tiene una lista privada `_obreros`. La pantalla no la toca directamente; solo usa:
  - `listar()`: espera 500 ms y devuelve la lista.
  - `crear()`: espera 700 ms y guarda el obrero.
- **Regla de negocio:** no se pueden guardar dos obreros con el mismo celular. Si pasa, el servicio lanza un `StateError` y la pantalla muestra el mensaje sin agregar nada.
- El `Future.delayed` solo simula el tiempo de respuesta de una API; no hay internet ni servidor.

## Estados en la pantalla

- **Cargando:** círculo de carga mientras `listar()` responde (se llama en `initState`).
- **Lista vacía:** mensaje que invita a llenar el formulario.
- **Guardando:** el botón se desactiva y muestra un círculo, así no se puede guardar dos veces.
- **Guardado correcto:** mensaje "Obrero guardado.", el obrero aparece en la lista y el formulario se limpia.
- **Error:** mensaje "Ya tienes un obrero con ese teléfono." y lo escrito se conserva.

Se usa `try`, `catch` y `finally`, se revisa `mounted` después de cada `await` y los controladores se liberan en `dispose()`.

## Límite de los datos en memoria

Los obreros se guardan solo en la memoria de la app. **Al cerrar la app se borran**; esto es esperado. En cambio, los **trabajos publicados** siguen guardados con SharedPreferences como en el taller anterior.

## Pruebas manuales

| Caso | Acción | Resultado |
| --- | --- | --- |
| Campos vacíos | Pulsar guardar sin escribir. | Salen los tres errores y no se agrega nada. |
| Texto muy corto | Nombre "Jo". | Sale "Usa al menos 3 letras." |
| Regla de dominio | Celular "12345" o sin elegir oficio. | Sale el mensaje del celular o "Elige en qué trabaja el obrero." |
| Registro válido | "Pedro Gómez", "Instalar TV", "3001234567". | Se ve el círculo, el mensaje "Obrero guardado." y Pedro en la lista. |
| Error de negocio | Guardar otro obrero con "3001234567". | Sale "Ya tienes un obrero con ese teléfono." y no se duplica. |
| Envío rápido | Pulsar guardar varias veces seguidas. | El botón se desactiva; solo se crea un obrero. |
| Reinicio | Cerrar y abrir la app. | Los trabajos publicados siguen; la lista de obreros queda vacía. |

## Capturas del taller 2

| Formulario | Validación | Resultado |
| --- | --- | --- |
| ![Formulario](capturas/obreros_formulario.png) | ![Validación](capturas/obreros_validacion.png) | ![Resultado](capturas/obreros_resultado.png) |

## Uso de IA (taller 2)

Usé Claude para generar la pantalla de obreros, el modelo y el servicio en memoria con el código más simple posible. Revisé y probé el flujo, y puedo explicar cada archivo.
