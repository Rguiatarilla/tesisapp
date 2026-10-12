import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';

// ─── Datos del desafío CAPTCHA ────────────────────────────────────────────────
class _CaptchaChallenge {
  final String instruccion;
  final List<String> emojis;
  final List<int> correctos; // índices correctos

  const _CaptchaChallenge({
    required this.instruccion,
    required this.emojis,
    required this.correctos,
  });
}

const _desafios = [
  _CaptchaChallenge(
    instruccion: 'Selecciona todos los\nautomóviles',
    emojis: ['🚗', '🌳', '🚗', '🏠', '🚗', '🐕', '🌳', '🚗', '🏠'],
    correctos: [0, 2, 4, 7],
  ),
  _CaptchaChallenge(
    instruccion: 'Selecciona todas las\nbocas de incendio',
    emojis: ['🚒', '🚗', '🚒', '🌳', '🚒', '🏠', '🚗', '🚒', '🌳'],
    correctos: [0, 2, 4, 7],
  ),
  _CaptchaChallenge(
    instruccion: 'Selecciona todos los\nsemáforos',
    emojis: ['🚦', '🚗', '🌳', '🚦', '🏠', '🚦', '🐕', '🌳', '🚦'],
    correctos: [0, 3, 5, 8],
  ),
  _CaptchaChallenge(
    instruccion: 'Selecciona todos los\nautobuses',
    emojis: ['🚌', '🚗', '🚌', '🌳', '🏠', '🚌', '🐕', '🚌', '🚗'],
    correctos: [0, 2, 5, 7],
  ),
  _CaptchaChallenge(
    instruccion: 'Selecciona todas las\nbicicletas',
    emojis: ['🚲', '🚗', '🌳', '🚲', '🏠', '🚗', '🚲', '🌳', '🚲'],
    correctos: [0, 3, 6, 8],
  ),
  _CaptchaChallenge(
    instruccion: 'Selecciona todos los\nbarcos',
    emojis: ['⛵', '🚗', '⛵', '🌳', '🏠', '⛵', '🚗', '🌳', '⛵'],
    correctos: [0, 2, 5, 8],
  ),
];

// ─── Widget CAPTCHA ───────────────────────────────────────────────────────────
class _CaptchaWidget extends StatefulWidget {
  final ValueChanged<bool> onVerificado;
  const _CaptchaWidget({required this.onVerificado});

  @override
  State<_CaptchaWidget> createState() => _CaptchaWidgetState();
}

class _CaptchaWidgetState extends State<_CaptchaWidget> {
  // Estados: 'idle' | 'challenge' | 'ok' | 'error'
  String _estado = 'idle';
  late _CaptchaChallenge _desafio;
  final Set<int> _seleccionados = {};

  void _iniciarDesafio() {
    final rng = Random();
    _desafio = _desafios[rng.nextInt(_desafios.length)];
    _seleccionados.clear();
    setState(() => _estado = 'challenge');
  }

  void _toggleCelda(int i) {
    setState(() {
      if (_seleccionados.contains(i)) {
        _seleccionados.remove(i);
      } else {
        _seleccionados.add(i);
      }
    });
  }

  void _verificar() {
    final correctSet = _desafio.correctos.toSet();
    if (_seleccionados.length == correctSet.length &&
        _seleccionados.every((i) => correctSet.contains(i))) {
      setState(() { _estado = 'ok'; });
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) setState(() {});
      });
      widget.onVerificado(true);
    } else {
      setState(() => _estado = 'error');
      widget.onVerificado(false);
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) _iniciarDesafio();
      });
    }
  }

  void _reintentar() => _iniciarDesafio();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Caja principal estilo reCAPTCHA
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: _estado == 'ok'
                  ? AppTheme.verde
                  : _estado == 'error'
                      ? AppTheme.rojo
                      : const Color(0xFFD3D3D3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Row(
              children: [
                // Checkbox animado
                GestureDetector(
                  onTap: _estado == 'idle' ? _iniciarDesafio : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _estado == 'ok' ? AppTheme.verde : Colors.white,
                      border: Border.all(
                        color: _estado == 'ok'
                            ? AppTheme.verde
                            : const Color(0xFF9E9E9E),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: _estado == 'ok'
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                ),
                const SizedBox(width: 14),
                // Texto
                Expanded(
                  child: Text(
                    _estado == 'ok' ? 'Verificado' : 'No soy un robot',
                    style: TextStyle(
                      fontSize: 15,
                      color: _estado == 'ok' ? AppTheme.verde : const Color(0xFF333333),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Logo reCAPTCHA
                Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4285F4), Color(0xFF34A853)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Center(
                        child: Text('rC', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text('reCAPTCHA', style: TextStyle(fontSize: 7, color: Color(0xFF9E9E9E))),
                    const Text('Privacidad - Términos', style: TextStyle(fontSize: 6, color: Color(0xFF9E9E9E))),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Panel del desafío
        if (_estado == 'challenge' || _estado == 'error')
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD3D3D3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Cabecera del desafío
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF4A90D9),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selecciona todas las imágenes que correspondan',
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _desafio.instruccion,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Grid 3x3
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 3,
                      crossAxisSpacing: 3,
                    ),
                    itemCount: 9,
                    itemBuilder: (_, i) {
                      final seleccionado = _seleccionados.contains(i);
                      return GestureDetector(
                        onTap: () => _toggleCelda(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: seleccionado
                                ? const Color(0xFF4A90D9).withValues(alpha: 0.15)
                                : Colors.grey.shade100,
                            border: Border.all(
                              color: seleccionado
                                  ? const Color(0xFF4A90D9)
                                  : Colors.grey.shade300,
                              width: seleccionado ? 3 : 1,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Text(
                                  _desafio.emojis[i],
                                  style: const TextStyle(fontSize: 36),
                                ),
                              ),
                              if (seleccionado)
                                Positioned(
                                  bottom: 4,
                                  right: 4,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF4A90D9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.check, color: Colors.white, size: 13),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Botones inferiores
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Botón reintentar
                      IconButton(
                        onPressed: _reintentar,
                        icon: const Icon(Icons.refresh, color: Color(0xFF4A90D9)),
                        tooltip: 'Nuevo desafío',
                      ),
                      if (_estado == 'error')
                        const Text(
                          'Incorrecto, intenta de nuevo...',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      // Botón verificar
                      ElevatedButton(
                        onPressed: _seleccionados.isEmpty ? null : _verificar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A90D9),
                          minimumSize: const Size(90, 36),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          textStyle: const TextStyle(fontSize: 13),
                        ),
                        child: const Text('Verificar'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ─── Pantalla de Registro ─────────────────────────────────────────────────────
class RegisterScreen extends ConsumerStatefulWidget {
  final VoidCallback? onGoToLogin;
  const RegisterScreen({super.key, this.onGoToLogin});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _fincaCtrl = TextEditingController();
  final _celularCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _captchaOk = false;
  bool _intentoEnviar = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _fincaCtrl.dispose();
    _celularCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _intentoEnviar = true);
    if (!_formKey.currentState!.validate()) return;
    if (!_captchaOk) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa la verificación reCAPTCHA'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    final ok = await ref.read(authProvider.notifier).register(
      _nombreCtrl.text.trim(),
      _fincaCtrl.text.trim(),
      _passCtrl.text,
      celular: _celularCtrl.text.trim(),
    );
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.read(authProvider).error ?? 'Error'),
          backgroundColor: AppTheme.rojo,
        ),
      );
    }
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
              const SizedBox(height: 24),
              const Text('🌱', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 6),
              const Text('AgroApp', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              const Text('Tu asistente agrícola', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.fondo,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Crear cuenta',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.verde)),
                          const SizedBox(height: 4),
                          const Text('Ingresa tus datos para comenzar',
                              style: TextStyle(color: Colors.grey, fontSize: 14)),
                          const SizedBox(height: 22),

                          // Nombre completo
                          _label('Nombre completo'),
                          TextFormField(
                            controller: _nombreCtrl,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person_outline, color: AppTheme.verdeClaro),
                              hintText: 'Ej: Juan Carlos Pérez',
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Ingresa tu nombre completo';
                              if (v.trim().split(' ').length < 2) return 'Ingresa nombre y apellido';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Nombre de la finca
                          _label('Nombre de la finca'),
                          TextFormField(
                            controller: _fincaCtrl,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.landscape, color: AppTheme.verdeClaro),
                              hintText: 'Ej: La Esperanza',
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? 'Ingresa el nombre de la finca' : null,
                          ),
                          const SizedBox(height: 14),

                          // Número de celular
                          _label('Número de celular'),
                          TextFormField(
                            controller: _celularCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.phone_android, color: AppTheme.verdeClaro),
                              hintText: 'Ej: 3001234567',
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Ingresa tu número de celular';
                              final digits = v.trim().replaceAll(RegExp(r'\D'), '');
                              if (digits.length < 10) return 'Ingresa un número válido (10 dígitos)';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Contraseña
                          _label('Contraseña'),
                          TextFormField(
                            controller: _passCtrl,
                            obscureText: _obscurePass,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.verdeClaro),
                              hintText: 'Mínimo 6 caracteres',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: Colors.grey,
                                ),
                                onPressed: () => setState(() => _obscurePass = !_obscurePass),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.length < 6) return 'Mínimo 6 caracteres';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Verificar contraseña
                          _label('Verificar contraseña'),
                          TextFormField(
                            controller: _confirmPassCtrl,
                            obscureText: _obscureConfirm,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock_person_outlined, color: AppTheme.verdeClaro),
                              hintText: 'Repite tu contraseña',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: Colors.grey,
                                ),
                                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Confirma tu contraseña';
                              if (v != _passCtrl.text) return 'Las contraseñas no coinciden';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // reCAPTCHA
                          _label('Verificación de seguridad'),
                          _CaptchaWidget(
                            onVerificado: (ok) => setState(() => _captchaOk = ok),
                          ),
                          if (_intentoEnviar && !_captchaOk)
                            const Padding(
                              padding: EdgeInsets.only(top: 6, left: 4),
                              child: Text(
                                'Completa la verificación reCAPTCHA',
                                style: TextStyle(color: AppTheme.rojo, fontSize: 12),
                              ),
                            ),
                          const SizedBox(height: 24),

                          // Botón registrar
                          ElevatedButton(
                            onPressed: isLoading ? null : _submit,
                            child: isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text('Registrarme'),
                          ),
                          const SizedBox(height: 14),

                          Center(
                            child: TextButton(
                              onPressed: widget.onGoToLogin,
                              child: const Text.rich(TextSpan(children: [
                                TextSpan(text: '¿Ya tienes cuenta? ', style: TextStyle(color: Colors.grey)),
                                TextSpan(
                                  text: 'Inicia sesión',
                                  style: TextStyle(color: AppTheme.verde, fontWeight: FontWeight.bold),
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
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.tierra),
        ),
      );
}
