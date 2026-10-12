import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/cultivo_model.dart';
import '../../models/actividad_model.dart';
import '../../viewmodels/cultivo_viewmodel.dart';
import '../../theme/app_theme.dart';
import '../../services/cultivo_service.dart';

// ── Provider para actividades personalizadas guardadas en alertas ─────────────
final actividadesPersonalizadasProvider =
    StateNotifierProvider<_ActPersonalizadasNotifier, List<String>>(
  (_) => _ActPersonalizadasNotifier(),
);

class _ActPersonalizadasNotifier extends StateNotifier<List<String>> {
  _ActPersonalizadasNotifier() : super([]);
  void agregar(String nombre) {
    if (nombre.isNotEmpty && !state.contains(nombre)) {
      state = [...state, nombre];
    }
  }
}

// ── Pantalla principal de Actividades con Calendario ─────────────────────────
class ActividadesScreen extends ConsumerStatefulWidget {
  final CultivoModel cultivo;
  const ActividadesScreen({super.key, required this.cultivo});

  @override
  ConsumerState<ActividadesScreen> createState() => _ActividadesScreenState();
}

class _ActividadesScreenState extends ConsumerState<ActividadesScreen> {
  DateTime _mesActual = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _diaSeleccionado;
  Set<String> _diasConActividades = {};

  static const _meses = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  @override
  void initState() {
    super.initState();
    _cargarDiasConActividades();
  }

  Future<void> _cargarDiasConActividades() async {
    final dias = await CultivoService().getDiasConActividades(
        widget.cultivo.id, _mesActual.year, _mesActual.month);
    if (mounted) setState(() => _diasConActividades = dias);
  }

  void _cambiarMes(int delta) {
    setState(() {
      _mesActual = DateTime(_mesActual.year, _mesActual.month + delta);
      _diaSeleccionado = null;
    });
    _cargarDiasConActividades();
  }

  void _abrirFormulario({ActividadModel? editar}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FormularioActividad(
        cultivoId: widget.cultivo.id,
        fechaInicial: _diaSeleccionado ?? DateTime.now(),
        editar: editar,
        onGuardado: _cargarDiasConActividades,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final actividades = ref.watch(actividadProvider(widget.cultivo.id));
    final actividadesDia = _diaSeleccionado == null
        ? <ActividadModel>[]
        : actividades
            .where((a) =>
                a.fecha.year == _diaSeleccionado!.year &&
                a.fecha.month == _diaSeleccionado!.month &&
                a.fecha.day == _diaSeleccionado!.day)
            .toList();

    return Scaffold(
      backgroundColor: AppTheme.fondo,
      appBar: AppBar(
        backgroundColor: AppTheme.verde,
        title: Text(widget.cultivo.tipo),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '${widget.cultivo.ubicacion} · ${widget.cultivo.areHectareas} ha',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.verde,
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // ── Calendario ──────────────────────────────────────────────
          Container(
            color: Colors.white,
            child: Column(
              children: [
                // Navegación de mes
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: AppTheme.verde),
                        onPressed: () => _cambiarMes(-1),
                      ),
                      Text(
                        '${_meses[_mesActual.month - 1]} ${_mesActual.year}',
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.verde),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: AppTheme.verde),
                        onPressed: () => _cambiarMes(1),
                      ),
                    ],
                  ),
                ),
                // Cabecera días
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb']
                        .map((d) => Expanded(
                              child: Center(
                                child: Text(d,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey)),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 4),
                // Grid de días
                _CalendarioGrid(
                  mes: _mesActual,
                  diaSeleccionado: _diaSeleccionado,
                  diasConActividades: _diasConActividades,
                  onDiaTap: (fecha) {
                    setState(() => _diaSeleccionado = fecha);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // ── Lista de actividades del día seleccionado ────────────────
          Expanded(
            child: _diaSeleccionado == null
                ? _buildTodas(actividades)
                : _buildDia(actividadesDia),
          ),
        ],
      ),
    );
  }

  Widget _buildTodas(List<ActividadModel> actividades) {
    if (actividades.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('📋', style: TextStyle(fontSize: 48)),
            SizedBox(height: 12),
            Text('Sin actividades registradas',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            Text('Toca un día del calendario o el botón +',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 14, 16, 6),
          child: Text('Todas las actividades',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 13)),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            itemCount: actividades.length,
            itemBuilder: (_, i) => _ActividadTile(
              actividad: actividades[i],
              cultivoId: widget.cultivo.id,
              onEditar: () => _abrirFormulario(editar: actividades[i]),
              onEliminado: _cargarDiasConActividades,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDia(List<ActividadModel> actividades) {
    final d = _diaSeleccionado!;
    final titulo =
        '${d.day} de ${_meses[d.month - 1]} de ${d.year}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
          child: Row(
            children: [
              Text(titulo,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: AppTheme.verde, fontSize: 14)),
              const Spacer(),
              TextButton.icon(
                onPressed: () => setState(() => _diaSeleccionado = null),
                icon: const Icon(Icons.close, size: 14),
                label: const Text('Ver todas', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(foregroundColor: Colors.grey),
              ),
            ],
          ),
        ),
        if (actividades.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('📅', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 8),
                  const Text('Sin actividades este día',
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _abrirFormulario(),
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar actividad'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.verde),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              itemCount: actividades.length,
              itemBuilder: (_, i) => _ActividadTile(
                actividad: actividades[i],
                cultivoId: widget.cultivo.id,
                onEditar: () => _abrirFormulario(editar: actividades[i]),
                onEliminado: _cargarDiasConActividades,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Grid del calendario ───────────────────────────────────────────────────────
class _CalendarioGrid extends StatelessWidget {
  final DateTime mes;
  final DateTime? diaSeleccionado;
  final Set<String> diasConActividades;
  final ValueChanged<DateTime> onDiaTap;

  const _CalendarioGrid({
    required this.mes,
    required this.diaSeleccionado,
    required this.diasConActividades,
    required this.onDiaTap,
  });

  @override
  Widget build(BuildContext context) {
    final primerDia = DateTime(mes.year, mes.month, 1);
    final offset = primerDia.weekday % 7; // 0=Dom
    final diasEnMes = DateUtils.getDaysInMonth(mes.year, mes.month);
    final hoy = DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
        ),
        itemCount: offset + diasEnMes,
        itemBuilder: (_, index) {
          if (index < offset) return const SizedBox();
          final dia = index - offset + 1;
          final fecha = DateTime(mes.year, mes.month, dia);
          final esHoy = fecha.year == hoy.year &&
              fecha.month == hoy.month &&
              fecha.day == hoy.day;
          final esSeleccionado = diaSeleccionado != null &&
              fecha.year == diaSeleccionado!.year &&
              fecha.month == diaSeleccionado!.month &&
              fecha.day == diaSeleccionado!.day;
          final tieneActividades = diasConActividades.contains('$dia');

          return GestureDetector(
            onTap: () => onDiaTap(fecha),
            child: Container(
              decoration: BoxDecoration(
                color: esSeleccionado
                    ? AppTheme.verde
                    : esHoy
                        ? AppTheme.verde.withValues(alpha: 0.12)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: esHoy && !esSeleccionado
                    ? Border.all(color: AppTheme.verde, width: 1.5)
                    : null,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    '$dia',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: esHoy || esSeleccionado
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: esSeleccionado
                          ? Colors.white
                          : esHoy
                              ? AppTheme.verde
                              : Colors.black87,
                    ),
                  ),
                  if (tieneActividades)
                    Positioned(
                      bottom: 3,
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: esSeleccionado
                              ? Colors.white
                              : AppTheme.verdeClaro,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Tile de actividad con editar y eliminar ───────────────────────────────────
class _ActividadTile extends ConsumerWidget {
  final ActividadModel actividad;
  final String cultivoId;
  final VoidCallback onEditar;
  final VoidCallback onEliminado;

  const _ActividadTile({
    required this.actividad,
    required this.cultivoId,
    required this.onEditar,
    required this.onEliminado,
  });

  static const _iconos = {
    'Siembra': Icons.eco,
    'Riego': Icons.water_drop,
    'Fertilización': Icons.science,
    'Fumigación': Icons.bug_report,
    'Cosecha': Icons.agriculture,
    'Otro': Icons.task_alt,
  };

  static const _colores = {
    'Siembra': AppTheme.verde,
    'Riego': AppTheme.azul,
    'Fertilización': Color(0xFF00695C),
    'Fumigación': AppTheme.naranja,
    'Cosecha': Color(0xFF4E342E),
    'Otro': AppTheme.morado,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final icono = _iconos[actividad.tipo] ?? Icons.task_alt;
    final color = _colores[actividad.tipo] ?? AppTheme.morado;
    final fecha =
        '${actividad.fecha.day}/${actividad.fecha.month}/${actividad.fecha.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 72,
            decoration: BoxDecoration(
              color: color,
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(14)),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icono, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(actividad.tipo,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(fecha,
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 12)),
                  if (actividad.notas.isNotEmpty)
                    Text(actividad.notas,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            height: 1.3)),
                ],
              ),
            ),
          ),
          // Botones editar / eliminar
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
        title: const Text('Eliminar actividad'),
        content: Text(
            '¿Eliminar "${actividad.tipo}" del ${actividad.fecha.day}/${actividad.fecha.month}/${actividad.fecha.year}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(actividadProvider(cultivoId).notifier)
                  .eliminar(actividad.id);
              onEliminado();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.rojo),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

// ── Formulario agregar / editar actividad ─────────────────────────────────────
class _FormularioActividad extends ConsumerStatefulWidget {
  final String cultivoId;
  final DateTime fechaInicial;
  final ActividadModel? editar;
  final VoidCallback onGuardado;

  const _FormularioActividad({
    required this.cultivoId,
    required this.fechaInicial,
    this.editar,
    required this.onGuardado,
  });

  @override
  ConsumerState<_FormularioActividad> createState() =>
      _FormularioActividadState();
}

class _FormularioActividadState extends ConsumerState<_FormularioActividad> {
  final _formKey = GlobalKey<FormState>();
  final _notasCtrl = TextEditingController();
  final _otroCtrl = TextEditingController();
  late String _tipoSeleccionado;
  late DateTime _fecha;
  bool _esOtro = false;

  static const _tipos = [
    'Siembra', 'Riego', 'Fertilización', 'Fumigación', 'Cosecha', 'Otro'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.editar != null) {
      final a = widget.editar!;
      _tipoSeleccionado = _tipos.contains(a.tipo) ? a.tipo : 'Otro';
      _esOtro = !_tipos.contains(a.tipo) || a.tipo == 'Otro';
      if (!_tipos.contains(a.tipo)) _otroCtrl.text = a.tipo;
      _notasCtrl.text = a.notas;
      _fecha = a.fecha;
    } else {
      _tipoSeleccionado = 'Siembra';
      _fecha = widget.fechaInicial;
    }
  }

  @override
  void dispose() {
    _notasCtrl.dispose();
    _otroCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    // Si es "Otro", usar el texto escrito como tipo
    final tipoFinal =
        (_tipoSeleccionado == 'Otro' && _otroCtrl.text.trim().isNotEmpty)
            ? _otroCtrl.text.trim()
            : _tipoSeleccionado;

    // Guardar actividad personalizada en el provider de alertas
    if (_tipoSeleccionado == 'Otro' && _otroCtrl.text.trim().isNotEmpty) {
      ref
          .read(actividadesPersonalizadasProvider.notifier)
          .agregar(_otroCtrl.text.trim());
    }

    final actividad = ActividadModel(
      id: widget.editar?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      cultivoId: widget.cultivoId,
      tipo: tipoFinal,
      fecha: _fecha,
      notas: _notasCtrl.text.trim(),
    );

    if (widget.editar != null) {
      await ref
          .read(actividadProvider(widget.cultivoId).notifier)
          .editar(actividad);
    } else {
      await ref
          .read(actividadProvider(widget.cultivoId).notifier)
          .agregar(actividad);
    }

    widget.onGuardado();
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
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                esEdicion ? 'Editar Actividad ✏️' : 'Nueva Actividad 🌿',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.verde),
              ),
              const SizedBox(height: 18),

              // Tipo de actividad
              _label('Tipo de actividad'),
              DropdownButtonFormField<String>(
                initialValue: _tipoSeleccionado,
                decoration: _inputDeco('Selecciona el tipo', Icons.task_alt),
                items: _tipos
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    _tipoSeleccionado = v ?? 'Siembra';
                    _esOtro = _tipoSeleccionado == 'Otro';
                  });
                },
              ),
              const SizedBox(height: 12),

              // Campo libre si es "Otro"
              if (_esOtro) ...[
                _label('Nombre de la actividad'),
                TextFormField(
                  controller: _otroCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _inputDeco(
                      'Ej: Aplicación de fungicida, Poda...', Icons.edit),
                  validator: (v) => (_esOtro &&
                          (v == null || v.trim().isEmpty))
                      ? 'Escribe el nombre de la actividad'
                      : null,
                ),
                const SizedBox(height: 4),
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text(
                    '💡 Esta actividad se guardará en tus alertas personalizadas',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.morado,
                        fontStyle: FontStyle.italic),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Fecha
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
                          primary: AppTheme.verde,
                          onPrimary: Colors.white,
                        ),
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
                        '${_fecha.day} / ${_fecha.month} / ${_fecha.year}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down,
                          color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Notas
              _label('Notas (opcional)'),
              TextFormField(
                controller: _notasCtrl,
                decoration: _inputDeco(
                    'Observaciones, cantidad, producto usado...', Icons.notes),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // Botón guardar
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
                  child: Text(
                    esEdicion ? 'Guardar cambios' : 'Guardar actividad',
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
        prefixIcon: Icon(icon, color: AppTheme.verdeClaro, size: 20),
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
