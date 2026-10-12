import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/cultivo_model.dart';
import '../../viewmodels/cultivo_viewmodel.dart';
import '../../theme/app_theme.dart';
import '../actividades/actividades_screen.dart';
import '../novedades/novedades_screen.dart';
import '../produccion/produccion_screen.dart';
import '../reporte/reporte_screen.dart';

class CultivosScreen extends ConsumerWidget {
  final String usuarioNombre;
  const CultivosScreen({super.key, required this.usuarioNombre});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cultivos = ref.watch(cultivoProvider(usuarioNombre));

    return Scaffold(
      backgroundColor: AppTheme.fondo,
      appBar: AppBar(
        backgroundColor: AppTheme.verde,
        title: const Text('Mis Cultivos',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.verde,
        onPressed: () => _mostrarFormulario(context, ref),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: cultivos.isEmpty
          ? const _EstadoVacio()
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: cultivos.length,
              itemBuilder: (_, i) => _CultivoCard(
                cultivo: cultivos[i],
                usuarioNombre: usuarioNombre,
                onEliminar: () => ref
                    .read(cultivoProvider(usuarioNombre).notifier)
                    .eliminar(cultivos[i].id),
              ),
            ),
    );
  }

  void _mostrarFormulario(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FormularioCultivo(usuarioNombre: usuarioNombre),
    );
  }
}

// ── Estado vacío ──────────────────────────────────────────────────────────────
class _EstadoVacio extends StatelessWidget {
  const _EstadoVacio();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🌿', style: TextStyle(fontSize: 56)),
          SizedBox(height: 12),
          Text('No tienes cultivos registrados',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 16)),
          SizedBox(height: 6),
          Text('Toca + para agregar tu primer lote',
              style: TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}

// ── Tarjeta de cultivo con 4 acciones ────────────────────────────────────────
class _CultivoCard extends StatelessWidget {
  final CultivoModel cultivo;
  final String usuarioNombre;
  final VoidCallback onEliminar;

  const _CultivoCard({
    required this.cultivo,
    required this.usuarioNombre,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final siembra = cultivo.fechaSiembra;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Encabezado verde ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
            decoration: BoxDecoration(
              color: AppTheme.verde.withValues(alpha: 0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppTheme.verde.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.grass,
                      color: AppTheme.verde, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cultivo.tipo,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppTheme.verde)),
                      Text(
                        cultivo.etapaCultivo,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppTheme.rojo, size: 20),
                  onPressed: () => _confirmarEliminar(context),
                  tooltip: 'Eliminar cultivo',
                ),
              ],
            ),
          ),
          // ── Datos del cultivo ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                _DatoChip(
                    icono: Icons.location_on,
                    texto: cultivo.ubicacion),
                _DatoChip(
                    icono: Icons.square_foot,
                    texto: '${cultivo.areHectareas} ha'),
                _DatoChip(
                    icono: Icons.calendar_today,
                    texto:
                        '${siembra.day}/${siembra.month}/${siembra.year}'),
                if (cultivo.altitud > 0)
                  _DatoChip(
                      icono: Icons.terrain,
                      texto:
                          '${cultivo.altitud.toStringAsFixed(0)} m.s.n.m.'),
              ],
            ),
          ),
          const Divider(height: 20, indent: 16, endIndent: 16),
          // ── Botones de acceso a secciones ─────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
            child: Row(
              children: [
                _AccionBtn(
                  emoji: '📅',
                  label: 'Actividades',
                  color: AppTheme.verde,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            ActividadesScreen(cultivo: cultivo)),
                  ),
                ),
                _AccionBtn(
                  emoji: '📋',
                  label: 'Novedades',
                  color: AppTheme.tierra,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            NovedadesScreen(cultivo: cultivo)),
                  ),
                ),
                _AccionBtn(
                  emoji: '☕',
                  label: 'Producción',
                  color: const Color(0xFF4E342E),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            ProduccionScreen(cultivo: cultivo)),
                  ),
                ),
                _AccionBtn(
                  emoji: '📊',
                  label: 'Reporte',
                  color: AppTheme.azul,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ReporteScreen(cultivo: cultivo)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminar(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar cultivo'),
        content: Text(
            '¿Eliminar "${cultivo.tipo}" y todas sus actividades, novedades y registros de producción?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onEliminar();
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.rojo),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

// ── Chip de dato ──────────────────────────────────────────────────────────────
class _DatoChip extends StatelessWidget {
  final IconData icono;
  final String texto;
  const _DatoChip({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 13, color: Colors.grey),
        const SizedBox(width: 3),
        Text(texto,
            style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}

// ── Botón de acción ───────────────────────────────────────────────────────────
class _AccionBtn extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AccionBtn({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 3),
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      color: color,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Formulario nuevo cultivo ──────────────────────────────────────────────────
class _FormularioCultivo extends ConsumerStatefulWidget {
  final String usuarioNombre;
  const _FormularioCultivo({required this.usuarioNombre});

  @override
  ConsumerState<_FormularioCultivo> createState() =>
      _FormularioCultivoState();
}

class _FormularioCultivoState extends ConsumerState<_FormularioCultivo> {
  final _formKey = GlobalKey<FormState>();
  final _ubicacionCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _altitudCtrl = TextEditingController();
  DateTime _fecha = DateTime.now();

  static const _tiposCultivo = [
    'Café Arábica',
    'Café Castillo',
    'Café Colombia',
    'Café Caturra',
    'Café Típica',
  ];

  static const _etapasCultivo = [
    'Semillero',
    'Almácigo',
    'Siembra',
    'Crecimiento',
    'Floración',
    'Fructificación',
    'Cosecha',
  ];

  String _tipoSeleccionado = 'Café Castillo';
  String _etapaSeleccionada = 'Crecimiento';

  @override
  void dispose() {
    _ubicacionCtrl.dispose();
    _areaCtrl.dispose();
    _altitudCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final cultivo = CultivoModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tipo: _tipoSeleccionado,
      fechaSiembra: _fecha,
      ubicacion: _ubicacionCtrl.text.trim(),
      areHectareas: double.parse(_areaCtrl.text.trim()),
      usuarioNombre: widget.usuarioNombre,
      altitud: _altitudCtrl.text.trim().isEmpty
          ? 0
          : double.tryParse(_altitudCtrl.text.trim()) ?? 0,
      etapaCultivo: _etapaSeleccionada,
    );
    await ref
        .read(cultivoProvider(widget.usuarioNombre).notifier)
        .agregar(cultivo);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Nuevo Lote de Café ☕',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.verde),
              ),
              const SizedBox(height: 18),
              _label('Variedad de café'),
              DropdownButtonFormField<String>(
                initialValue: _tipoSeleccionado,
                decoration:
                    _inputDecoration('Variedad', Icons.grass),
                items: _tiposCultivo
                    .map((t) =>
                        DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(
                    () => _tipoSeleccionado = v ?? 'Café Castillo'),
              ),
              const SizedBox(height: 12),
              _label('Etapa del cultivo'),
              DropdownButtonFormField<String>(
                initialValue: _etapaSeleccionada,
                decoration:
                    _inputDecoration('Etapa', Icons.timeline),
                items: _etapasCultivo
                    .map((e) =>
                        DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(
                    () => _etapaSeleccionada = v ?? 'Crecimiento'),
              ),
              const SizedBox(height: 12),
              _label('Ubicación / Lote'),
              TextFormField(
                controller: _ubicacionCtrl,
                decoration:
                    _inputDecoration('Ej: Lote La Esperanza', Icons.location_on),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Ingresa la ubicación'
                    : null,
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Área (hectáreas)'),
                        TextFormField(
                          controller: _areaCtrl,
                          decoration: _inputDecoration(
                              'Ej: 1.5', Icons.square_foot),
                          keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Ingresa el área';
                            }
                            if (double.tryParse(v.trim()) == null) {
                              return 'Número inválido';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Altitud (m.s.n.m.)'),
                        TextFormField(
                          controller: _altitudCtrl,
                          decoration: _inputDecoration(
                              'Ej: 1800', Icons.terrain),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _label('Fecha de siembra'),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _fecha,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    builder: (ctx, child) => Theme(
                      data: Theme.of(ctx).copyWith(
                        colorScheme: const ColorScheme.light(
                            primary: AppTheme.verde,
                            onPrimary: Colors.white),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) setState(() => _fecha = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.fondo,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: AppTheme.verde, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        '${_fecha.day}/${_fecha.month}/${_fecha.year}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down,
                          color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.verde,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Guardar cultivo',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
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
        child: Text(text,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black54)),
      );

  InputDecoration _inputDecoration(String hint, IconData icon) =>
      InputDecoration(
        hintText: hint,
        prefixIcon:
            Icon(icon, color: AppTheme.verdeClaro, size: 20),
        filled: true,
        fillColor: AppTheme.fondo,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppTheme.verdeClaro, width: 2)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.rojo)),
      );
}
