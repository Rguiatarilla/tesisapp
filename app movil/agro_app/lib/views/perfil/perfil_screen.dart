import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';

class PerfilScreen extends ConsumerStatefulWidget {
  const PerfilScreen({super.key});

  @override
  ConsumerState<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends ConsumerState<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreCtrl;
  late TextEditingController _fincaCtrl;
  late TextEditingController _celularCtrl;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nombreCtrl = TextEditingController(text: user?.nombre ?? '');
    _fincaCtrl = TextEditingController(text: user?.nombreFinca ?? '');
    _celularCtrl = TextEditingController(text: user?.celular ?? '');
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _fincaCtrl.dispose();
    _celularCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(authProvider).user;
    if (user == null) return;

    final service = ref.read(authServiceProvider);
    await service.actualizarPerfil(
      nombreActual: user.nombre,
      nuevoNombre: _nombreCtrl.text.trim(),
      nuevaFinca: _fincaCtrl.text.trim(),
      celular: _celularCtrl.text.trim(),
    );
    await ref.read(authProvider.notifier).checkSession();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente'),
          backgroundColor: AppTheme.verde,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppTheme.fondo,
      appBar: AppBar(
        backgroundColor: AppTheme.verde,
        title: const Text('Mi Perfil'),
        actions: [
          TextButton(
            onPressed: _guardar,
            child: const Text('Guardar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header verde con avatar ──────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: Colors.white.withValues(alpha: 0.25),
                        child: const Icon(Icons.person, size: 48, color: Colors.white),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, size: 16, color: AppTheme.verde),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.nombre ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Finca: ${user?.nombreFinca ?? ''}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {},
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.camera_alt_outlined, color: Colors.white70, size: 14),
                        SizedBox(width: 4),
                        Text('Cambiar foto', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Formulario ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Información personal',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.verde)),
                    const SizedBox(height: 16),

                    _label('Nombre'),
                    TextFormField(
                      controller: _nombreCtrl,
                      decoration: _inputDecoration('Nombre completo', Icons.person_outline),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'El nombre es obligatorio' : null,
                    ),
                    const SizedBox(height: 14),

                    _label('Nombre de la finca'),
                    TextFormField(
                      controller: _fincaCtrl,
                      decoration: _inputDecoration('Nombre de la finca', Icons.landscape),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'El nombre de la finca es obligatorio' : null,
                    ),
                    const SizedBox(height: 14),

                    _label('Número de celular'),
                    TextFormField(
                      controller: _celularCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecoration('Número de celular', Icons.phone_android),
                    ),
                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _guardar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.verdeClaro,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Guardar cambios',
                            style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Botón cerrar sesión
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () => ref.read(authProvider.notifier).logout(),
                        icon: const Icon(Icons.logout, color: AppTheme.rojo),
                        label: const Text('Cerrar sesión',
                            style: TextStyle(color: AppTheme.rojo, fontSize: 15)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.rojo),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54)),
      );

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppTheme.verdeClaro, size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.verdeClaro, width: 2)),
    );
  }
}
