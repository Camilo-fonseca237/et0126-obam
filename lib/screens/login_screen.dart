import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correo = TextEditingController();
  final _clave = TextEditingController();
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _correo.dispose();
    _clave.dispose();
    super.dispose();
  }

  Future<void> _ingresar() async {
    if (_cargando || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _correo.text.trim(),
        password: _clave.text,
      );
    } on FirebaseAuthException {
      if (mounted) {
        setState(() => _error = 'No se pudo iniciar sesión. Revisa tus datos.');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Error de conexión. Inténtalo de nuevo.');
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  // Inicia sesión o registra automáticamente al usuario con su cuenta de Google (Web).
  Future<void> _ingresarConGoogle() async {
    if (_cargando) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final proveedor = GoogleAuthProvider();
      proveedor.setCustomParameters({'prompt': 'select_account'});
      await FirebaseAuth.instance.signInWithPopup(proveedor);
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
    return 'No se pudo iniciar sesión con Google.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar sesión'),
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
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _correo,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || !v.contains('@'))
                      ? 'Escribe un correo válido'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _clave,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Escribe tu contraseña'
                      : null,
                ),
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
                    onPressed: _cargando ? null : _ingresar,
                    child: Text(_cargando ? 'Ingresando...' : 'Entrar'),
                  ),
                ),
                const SizedBox(height: 16),
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
