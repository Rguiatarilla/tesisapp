import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final VoidCallback? onGoToRegister;
  const LoginScreen({super.key, this.onGoToRegister});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authProvider.notifier).login(
          _nombreCtrl.text.trim(), _passCtrl.text);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.read(authProvider).error ?? 'Error'),
          backgroundColor: AppTheme.rojo,
        ),
      );
    }
  }

  void _mostrarRecuperarContrasena() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _RecuperarContrasenaSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
            begin: Alignment.topCenter,
            end: Alignment.center,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 32),
              const Text('🌾', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 8),
              const Text('AgroApp',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
              const Text('Bienvenido de nuevo',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.fondo,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Iniciar sesión',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.verde)),
                          const SizedBox(height: 4),
                          const Text('Ingresa con tu nombre y contraseña',
                              style: TextStyle(color: Colors.grey, fontSize: 14)),
                          const SizedBox(height: 28),

                          // Nombre
                          _label('Tu nombre'),
                          TextFormField(
                            controller: _nombreCtrl,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person_outline, color: AppTheme.verdeClaro),
                              hintText: 'Ej: Juan Pérez',
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? 'Ingresa tu nombre' : null,
                          ),
                          const SizedBox(height: 16),

                          // Contraseña
                          _label('Contraseña'),
                          TextFormField(
                            controller: _passCtrl,
                            obscureText: _obscurePass,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.verdeClaro),
                              hintText: 'Tu contraseña',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePass
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.grey,
                                ),
                                onPressed: () => setState(() => _obscurePass = !_obscurePass),
                              ),
                            ),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Ingresa tu contraseña' : null,
                          ),

                          // Recuperar contraseña
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _mostrarRecuperarContrasena,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                              ),
                              child: const Text(
                                '¿Olvidaste tu contraseña?',
                                style: TextStyle(
                                  color: AppTheme.azul,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Botón ingresar
                          ElevatedButton(
                            onPressed: isLoading ? null : _submit,
                            child: isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text('Ingresar'),
                          ),
                          const SizedBox(height: 16),

                          Center(
                            child: TextButton(
                              onPressed: widget.onGoToRegister,
                              child: const Text.rich(TextSpan(children: [
                                TextSpan(
                                    text: '¿No tienes cuenta? ',
                                    style: TextStyle(color: Colors.grey)),
                                TextSpan(
                                  text: 'Regístrate',
                                  style: TextStyle(
                                      color: AppTheme.verde,
                                      fontWeight: FontWeight.bold),
                                ),
                              ])),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.tierra),
        ),
      );
}

// ─── Sheet de recuperar contraseña ───────────────────────────────────────────
class _RecuperarContrasenaSheet extends ConsumerStatefulWidget {
  const _RecuperarContrasenaSheet();

  @override
  ConsumerState<_RecuperarContrasenaSheet> createState() =>
      _RecuperarContrasenaSheetState();
}

class _RecuperarContrasenaSheetState
    extends ConsumerState<_RecuperarContrasenaSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _celularCtrl = TextEditingController();
  final _nuevaPassCtrl = TextEditingController();
  bool _obscure = true;
  bool _exito = false;
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _celularCtrl.dispose();
    _nuevaPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _recuperar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _cargando = true; _error = null; });

    final ok = await ref.read(authProvider.notifier).recuperarContrasena(
      nombre: _nombreCtrl.text.trim(),
      celular: _celularCtrl.text.trim(),
      nuevaPassword: _nuevaPassCtrl.text,
    );

    if (mounted) {
      setState(() {
        _cargando = false;
        if (ok) {
          _exito = true;
        } else {
          _error = 'No se encontró un usuario con ese nombre y celular.\nVerifica los datos e intenta de nuevo.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: _exito ? _buildExito() : _buildFormulario(),
    );
  }

  Widget _buildExito() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('✅', style: TextStyle(fontSize: 56)),
        const SizedBox(height: 12),
        const Text(
          'Contraseña actualizada',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.verde),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tu contraseña fue cambiada exitosamente.\nYa puedes iniciar sesión con la nueva contraseña.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Volver al inicio de sesión'),
          ),
        ),
      ],
    );
  }

  Widget _buildFormulario() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          const Text('🔑', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          const Text(
            'Recuperar contraseña',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.verde),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ingresa tu nombre y celular registrado para restablecer tu contraseña.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Nombre
          _label('Tu nombre'),
          TextFormField(
            controller: _nombreCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.person_outline, color: AppTheme.verdeClaro),
              hintText: 'Nombre con el que te registraste',
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Ingresa tu nombre' : null,
          ),
          const SizedBox(height: 14),

          // Celular
          _label('Número de celular'),
          TextFormField(
            controller: _celularCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.phone_android, color: AppTheme.verdeClaro),
              hintText: 'Celular registrado',
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Ingresa tu celular';
              final digits = v.trim().replaceAll(RegExp(r'\D'), '');
              if (digits.length < 10) return 'Número inválido';
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Nueva contraseña
          _label('Nueva contraseña'),
          TextFormField(
            controller: _nuevaPassCtrl,
            obscureText: _obscure,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.verdeClaro),
              hintText: 'Mínimo 6 caracteres',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: Colors.grey,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            validator: (v) =>
                (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
          ),

          if (_error != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.rojo.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.rojo.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppTheme.rojo, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_error!,
                        style: const TextStyle(color: AppTheme.rojo, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _cargando ? null : _recuperar,
              child: _cargando
                  ? const SizedBox(
                      height: 22, width: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Restablecer contraseña'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.tierra),
        ),
      );
}
