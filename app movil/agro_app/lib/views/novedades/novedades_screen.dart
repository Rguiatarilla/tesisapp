import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/cultivo_model.dart';
import '../../models/novedad_model.dart';
import '../../viewmodels/cultivo_viewmodel.dart';
import '../../theme/app_theme.dart';

class NovedadesScreen extends ConsumerWidget {
  final CultivoModel cultivo;
  const NovedadesScreen({super.key, required this.cultivo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final novedades = ref.watch(novedadProvider(cultivo.id));

    return Scaffold(
      backgroundColor: AppTheme.fondo,
      appBar: AppBar(
        backgroundColor: AppTheme.tierra,
        title: Text('Novedades · ${cultivo.tipo}',
            style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '${cultivo.ubicacion} · ${cultivo.etapaCultivo}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.tierra,
        onPressed: () => _abrirFormulario(context, ref),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: novedades.isEmpty
          ? const _EstadoVacio()
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: novedades.length,
              itemBuilder: (_, i) => _NovedadTile(
                novedad: novedades[i],
                cultivoId: cultivo.id,
                onEditar: () => _abrirFormulario(context, ref, editar: novedades[i]),
              ),
            ),
    );
  }

  void _abrirFormulario(BuildContext context, WidgetRef ref,
      {NovedadModel? editar}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FormularioNovedad(
        cultivoId: cultivo.id,
        editar: editar,
      ),
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
          Text('📋', style: TextStyle(fontSize: 56)),
          SizedBox(height: 12),
          Text('Sin novedades registradas',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 16)),
          SizedBox(height: 6),
          Text('Toca + para registrar una novedad\ndel estado de tu cultivo',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}

// ── Tile de novedad ───────────────────────────────────────────────────────────
class _NovedadTile extends ConsumerWidget {
  final NovedadModel novedad;
  final String cultivoId;
  final VoidCallback onEditar;

  const _NovedadTile({
    required this.novedad,
    required this.cultivoId,
    required this.onEditar,
  });

  static const _iconosTipo = {
    'Plaga': Icons.bug_report,
    'Enfermedad': Icons.coronavirus,
    'Clima': Icons.cloud,
    'Crecimiento': Icons.trending_up,
    'Otro': Icons.note_alt,
  };

  static const _coloresTipo = {
    'Plaga': AppTheme.naranja,
    'Enfermedad': AppTheme.rojo,
    'Clima': AppTheme.azul,
    'Crecimiento': AppTheme.verde,
    'Otro': AppTheme.morado,
  };

  static const _coloresEstado = {
    'Normal': Color(0xFF2E7D32),
    'Atención': Color(0xFFE65100),
    'Crítico': Color(0xFFC62828),
  };

  static const _emojisEstado = {
    'Normal': '✅',
    'Atención': '⚠️',
    'Crítico': '🚨',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final icono = _iconosTipo[novedad.tipo] ?? Icons.note_alt;
    final colorTipo = _coloresTipo[novedad.tipo] ?? AppTheme.morado;
    final colorEstado = _coloresEstado[novedad.estado] ?? AppTheme.verde;
    final emojiEstado = _emojisEstado[novedad.estado] ?? '✅';
    final fecha =
        '${novedad.fecha.day}/${novedad.fecha.month}/${novedad.fecha.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con color del tipo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: colorTipo.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(icono, color: colorTipo, size: 18),
                const SizedBox(width: 8),
                Text(novedad.tipo,
                    style: TextStyle(
                        color: colorTipo,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: colorEstado.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: colorEstado.withValues(alpha: 0.3)),
                  ),
                  child: Text('$emojiEstado ${novedad.estado}',
                      style: TextStyle(
                          color: colorEstado,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          // Cuerpo
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(novedad.descripcion,
                    style: const TextStyle(fontSize: 14, height: 1.4)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(fecha,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined,
                          color: AppTheme.azul, size: 18),
                      onPressed: onEditar,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Editar',
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: AppTheme.rojo, size: 18),
                      onPressed: () => _confirmarEliminar(context, ref),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Eliminar',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminar(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar novedad'),
        content: const Text('¿Deseas eliminar esta novedad del cultivo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(novedadProvider(cultivoId).notifier)
                  .eliminar(novedad.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.rojo),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

// ── Formulario agregar / editar novedad ───────────────────────────────────────
class _FormularioNovedad extends ConsumerStatefulWidget {
  final String cultivoId;
  final NovedadModel? editar;

  const _FormularioNovedad({required this.cultivoId, this.editar});

  @override
  ConsumerState<_FormularioNovedad> createState() => _FormularioNovedadState();
}

class _FormularioNovedadState extends ConsumerState<_FormularioNovedad> {
  final _formKey = GlobalKey<FormState>();
  final _descripcionCtrl = TextEditingController();
  late String _tipoSeleccionado;
  late String _estadoSeleccionado;
  late DateTime _fecha;

  static const _tipos = ['Plaga', 'Enfermedad', 'Clima', 'Crecimiento', 'Otro'];
  static const _estados = ['Normal', 'Atención', 'Crítico'];

  @override
  void initState() {
    super.initState();
    if (widget.editar != null) {
      final n = widget.editar!;
      _tipoSeleccionado = n.tipo;
      _estadoSeleccionado = n.estado;
      _descripcionCtrl.text = n.descripcion;
      _fecha = n.fecha;
    } else {
      _tipoSeleccionado = 'Crecimiento';
      _estadoSeleccionado = 'Normal';
      _fecha = DateTime.now();
    }
  }

  @override
  void dispose() {
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final novedad = NovedadModel(
      id: widget.editar?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      cultivoId: widget.cultivoId,
      fecha: _fecha,
      descripcion: _descripcionCtrl.text.trim(),
      tipo: _tipoSeleccionado,
      estado: _estadoSeleccionado,
    );
    if (widget.editar != null) {
      await ref
          .read(novedadProvider(widget.cultivoId).notifier)
          .editar(novedad);
    } else {
      await ref
          .read(novedadProvider(widget.cultivoId).notifier)
          .agregar(novedad);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.editar != null;
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
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                esEdicion ? 'Editar Novedad ✏️' : 'Nueva Novedad 📋',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.tierra),
              ),
              const SizedBox(height: 18),
              _label('Tipo de novedad'),
              DropdownButtonFormField<String>(
                initialValue: _tipoSeleccionado,
                decoration: _inputDeco('Tipo', Icons.category),
                items: _tipos
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _tipoSeleccionado = v ?? 'Crecimiento'),
              ),
              const SizedBox(height: 12),
              _label('Estado del cultivo'),
              DropdownButtonFormField<String>(
                initialValue: _estadoSeleccionado,
                decoration: _inputDeco('Estado', Icons.monitor_heart),
                items: _estados
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _estadoSeleccionado = v ?? 'Normal'),
              ),
              const SizedBox(height: 12),
              _label('Fecha'),
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
                            primary: AppTheme.tierra, onPrimary: Colors.white),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) setState(() => _fecha = picked);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.fondo,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: AppTheme.tierra, size: 20),
                      const SizedBox(width: 12),
                      Text(
                          '${_fecha.day} / ${_fecha.month} / ${_fecha.year}',
                          style: const TextStyle(fontSize: 15)),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _label('Descripción / Observación'),
              TextFormField(
                controller: _descripcionCtrl,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: _inputDeco(
                    'Describe lo observado en el cultivo...', Icons.notes),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Escribe una descripción'
                    : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.tierra,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    esEdicion ? 'Guardar cambios' : 'Registrar novedad',
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
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
        child: Text(text,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black54)),
      );

  InputDecoration _inputDeco(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.tierra, size: 20),
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
            borderSide: const BorderSide(color: AppTheme.tierra, width: 2)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.rojo)),
      );
}
