import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _clave = TextEditingController();
  final _confirmarClave = TextEditingController();
  bool _modoRegistro = false;
  bool _ocultarClave = true;
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _clave.dispose();
    _confirmarClave.dispose();
    super.dispose();
  }

  void _cambiarModo() {
    setState(() {
      _modoRegistro = !_modoRegistro;
      _error = null;
      _confirmarClave.clear();
    });
    _formKey.currentState?.reset();
  }

  Future<void> _enviarFormulario() async {
    if (_cargando || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      if (_modoRegistro) {
        final credencial =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _correo.text.trim(),
          password: _clave.text,
        );
        final nombre = _nombre.text.trim();
        if (nombre.isNotEmpty) {
          await credencial.user?.updateDisplayName(nombre);
        }
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _correo.text.trim(),
          password: _clave.text,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(
          () => _error = _modoRegistro
              ? _mensajeErrorRegistro(e.code)
              : 'No se pudo iniciar sesión. Revisa tus datos.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Error de conexión. Inténtalo de nuevo.');
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  String _mensajeErrorRegistro(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Ese correo ya tiene una cuenta. Prueba iniciar sesión.';
      case 'weak-password':
        return 'La contraseña es muy débil. Usa al menos 6 caracteres.';
      case 'invalid-email':
        return 'El formato del correo no es válido.';
      case 'operation-not-allowed':
        return 'El registro con correo no está habilitado en Firebase.';
      case 'network-request-failed':
        return 'Error de conexión. Revisa tu internet e inténtalo de nuevo.';
      default:
        return 'No se pudo crear la cuenta ($code).';
    }
  }

  // Inicia sesión o registra automáticamente al usuario con su cuenta de Google.
  Future<void> _ingresarConGoogle() async {
    if (_cargando) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      if (kIsWeb) {
        final proveedor = GoogleAuthProvider();
        proveedor.setCustomParameters({'prompt': 'select_account'});
        await FirebaseAuth.instance.signInWithPopup(proveedor);
      } else {
        final cuenta = await GoogleSignIn.instance.authenticate();
        final auth = cuenta.authentication;
        final credencial = GoogleAuthProvider.credential(
          idToken: auth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credencial);
      }
    } on GoogleSignInException catch (e) {
      if (mounted) {
        setState(
          () => _error = e.code == GoogleSignInExceptionCode.canceled
              ? 'Se canceló el acceso con Google.'
              : 'No se pudo iniciar sesión con Google (${e.code.name}).',
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _error = _mensajeErrorGoogle(e.code));
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Error al conectar con Google. Inténtalo de nuevo.',
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  String _mensajeErrorGoogle(String code) {
    if (code == 'popup-closed-by-user' || code == 'cancelled-popup-request') {
      return 'Se canceló el acceso con Google.';
    }
    if (code == 'popup-blocked') {
      return 'El navegador bloqueó la ventana de Google. Permite ventanas emergentes.';
    }
    if (code == 'unauthorized-domain') {
      return 'Dominio no autorizado. Agrégalo en Firebase → Authentication → Dominios autorizados.';
    }
    return 'No se pudo iniciar sesión con Google ($code).';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_modoRegistro ? 'Crear cuenta' : 'Iniciar sesión'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Image.asset('assets/images/logo_obam.png', width: 96),
          ),
          const SizedBox(height: 12),
          const Text(
            'OBAM · Obrero a la mano',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            _modoRegistro
                ? 'Crea tu cuenta con correo y contraseña'
                : 'Ingresa para publicar o negociar trabajos',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: Column(
              children: [
                if (_modoRegistro) ...[
                  TextFormField(
                    controller: _nombre,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (!_modoRegistro) return null;
                      return (v == null || v.trim().length < 2)
                          ? 'Escribe tu nombre (mínimo 2 letras)'
                          : null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _correo,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || !v.trim().contains('@'))
                      ? 'Escribe un correo válido'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _clave,
                  obscureText: _ocultarClave,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    helperText:
                        _modoRegistro ? 'Mínimo 6 caracteres' : null,
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      tooltip: _ocultarClave
                          ? 'Mostrar contraseña'
                          : 'Ocultar contraseña',
                      icon: Icon(
                        _ocultarClave
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () =>
                          setState(() => _ocultarClave = !_ocultarClave),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Escribe tu contraseña';
                    }
                    if (_modoRegistro && v.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                if (_modoRegistro) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmarClave,
                    obscureText: _ocultarClave,
                    decoration: const InputDecoration(
                      labelText: 'Confirmar contraseña',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (!_modoRegistro) return null;
                      if (v == null || v.isEmpty) {
                        return 'Confirma tu contraseña';
                      }
                      if (v != _clave.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 16),
                if (_error != null) ...[
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _cargando ? null : _enviarFormulario,
                    child: Text(
                      _cargando
                          ? (_modoRegistro
                              ? 'Creando cuenta...'
                              : 'Ingresando...')
                          : (_modoRegistro ? 'Crear cuenta' : 'Entrar'),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _cargando ? null : _cambiarModo,
                  child: Text(
                    _modoRegistro
                        ? '¿Ya tienes cuenta? Inicia sesión'
                        : '¿No tienes cuenta? Crear cuenta',
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('o'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _cargando ? null : _ingresarConGoogle,
                    icon: const Icon(Icons.account_circle),
                    label: const Text('Continuar con Google'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
