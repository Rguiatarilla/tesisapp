import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/cultivo_model.dart';
import '../../models/produccion_model.dart';
import '../../viewmodels/cultivo_viewmodel.dart';
import '../../theme/app_theme.dart';

class ProduccionScreen extends ConsumerWidget {
  final CultivoModel cultivo;
  const ProduccionScreen({super.key, required this.cultivo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registros = ref.watch(produccionProvider(cultivo.id));

    // Totales por unidad para el resumen
    final totales = <String, double>{};
    for (final r in registros) {
      totales[r.unidad] = (totales[r.unidad] ?? 0) + r.cantidad;
    }

    return Scaffold(
      backgroundColor: AppTheme.fondo,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4E342E),
        title: Text('Producción · ${cultivo.tipo}',
            style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '${cultivo.ubicacion} · ${cultivo.areHectareas} ha',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4E342E),
        onPressed: () => _abrirFormulario(context, ref),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: registros.isEmpty
          ? const _EstadoVacio()
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              children: [
                // ── Resumen de totales ────────────────────────────────
                if (totales.isNotEmpty) _ResumenCard(totales: totales),
                const SizedBox(height: 16),
                // ── Lista de registros ────────────────────────────────
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Historial de cosechas',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black54),
                  ),
                ),
                ...registros.map((r) => _ProduccionTile(
                      produccion: r,
                      cultivoId: cultivo.id,
                      onEditar: () =>
                          _abrirFormulario(context, ref, editar: r),
                    )),
              ],
            ),
    );
  }

  void _abrirFormulario(BuildContext context, WidgetRef ref,
      {ProduccionModel? editar}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _FormularioProduccion(cultivoId: cultivo.id, editar: editar),
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
          Text('☕', style: TextStyle(fontSize: 56)),
          SizedBox(height: 12),
          Text('Sin registros de producción',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 16)),
          SizedBox(height: 6),
          Text('Toca + para registrar una cosecha',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}

// ── Tarjeta de resumen ────────────────────────────────────────────────────────
class _ResumenCard extends StatelessWidget {
  final Map<String, double> totales;
  const _ResumenCard({required this.totales});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4E342E), Color(0xFF795548)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF4E342E).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('☕', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text('Producción total registrada',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: totales.entries
                .map((e) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${e.value.toStringAsFixed(1)} ${e.key}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ── Tile de registro de producción ────────────────────────────────────────────
class _ProduccionTile extends ConsumerWidget {
  final ProduccionModel produccion;
  final String cultivoId;
  final VoidCallback onEditar;

  const _ProduccionTile({
    required this.produccion,
    required this.cultivoId,
    required this.onEditar,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fecha =
        '${produccion.fechaCosecha.day}/${produccion.fechaCosecha.month}/${produccion.fechaCosecha.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFF4E342E),
              borderRadius:
                  BorderRadius.horizontal(left: Radius.circular(14)),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF4E342E).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
                child: Text('☕', style: TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${produccion.cantidad.toStringAsFixed(1)} ${produccion.unidad}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF4E342E)),
                  ),
                  Text(fecha,
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 12)),
                  if (produccion.notas.isNotEmpty)
                    Text(produccion.notas,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            height: 1.3)),
                ],
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: AppTheme.azul, size: 20),
                onPressed: onEditar,
                tooltip: 'Editar',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: AppTheme.rojo, size: 20),
                onPressed: () => _confirmarEliminar(context, ref),
                tooltip: 'Eliminar',
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  void _confirmarEliminar(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar registro'),
        content: const Text('¿Deseas eliminar este registro de producción?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(produccionProvider(cultivoId).notifier)
                  .eliminar(produccion.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.rojo),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

// ── Formulario agregar / editar producción ────────────────────────────────────
class _FormularioProduccion extends ConsumerStatefulWidget {
  final String cultivoId;
  final ProduccionModel? editar;

  const _FormularioProduccion({required this.cultivoId, this.editar});

  @override
  ConsumerState<_FormularioProduccion> createState() =>
      _FormularioProduccionState();
}

class _FormularioProduccionState
    extends ConsumerState<_FormularioProduccion> {
  final _formKey = GlobalKey<FormState>();
  final _cantidadCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();
  late String _unidadSeleccionada;
  late DateTime _fecha;

  static const _unidades = ['kg', 'cargas', 'bultos', 'arrobas'];

  @override
  void initState() {
    super.initState();
    if (widget.editar != null) {
      final p = widget.editar!;
      _cantidadCtrl.text = p.cantidad.toString();
      _unidadSeleccionada = p.unidad;
      _notasCtrl.text = p.notas;
      _fecha = p.fechaCosecha;
    } else {
      _unidadSeleccionada = 'kg';
      _fecha = DateTime.now();
    }
  }

  @override
  void dispose() {
    _cantidadCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final prod = ProduccionModel(
      id: widget.editar?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      cultivoId: widget.cultivoId,
      fechaCosecha: _fecha,
      cantidad: double.parse(_cantidadCtrl.text.trim()),
      unidad: _unidadSeleccionada,
      notas: _notasCtrl.text.trim(),
    );
    if (widget.editar != null) {
      await ref
          .read(produccionProvider(widget.cultivoId).notifier)
          .editar(prod);
    } else {
      await ref
          .read(produccionProvider(widget.cultivoId).notifier)
          .agregar(prod);
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
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                esEdicion ? 'Editar Cosecha ✏️' : 'Registrar Cosecha ☕',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4E342E)),
              ),
              const SizedBox(height: 18),
              _label('Fecha de cosecha'),
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
                            primary: Color(0xFF4E342E),
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
                          color: Color(0xFF4E342E), size: 20),
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
              _label('Cantidad producida'),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _cantidadCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: _inputDeco('Ej: 125', Icons.scale),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Ingresa la cantidad';
                        }
                        if (double.tryParse(v.trim()) == null) {
                          return 'Número inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: _unidadSeleccionada,
                      decoration: _inputDeco('Unidad', Icons.straighten),
                      items: _unidades
                          .map((u) =>
                              DropdownMenuItem(value: u, child: Text(u)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _unidadSeleccionada = v ?? 'kg'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _label('Notas (opcional)'),
              TextFormField(
                controller: _notasCtrl,
                maxLines: 3,
                decoration: _inputDeco(
                    'Calidad, destino, precio obtenido...', Icons.notes),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4E342E),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    esEdicion ? 'Guardar cambios' : 'Registrar cosecha',
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
        prefixIcon: Icon(icon, color: const Color(0xFF4E342E), size: 20),
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
            borderSide: const BorderSide(
                color: Color(0xFF4E342E), width: 2)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.rojo)),
      );
}
