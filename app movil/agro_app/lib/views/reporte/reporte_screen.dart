import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/cultivo_model.dart';
import '../../models/actividad_model.dart';
import '../../models/novedad_model.dart';
import '../../models/produccion_model.dart';
import '../../viewmodels/cultivo_viewmodel.dart';
import '../../theme/app_theme.dart';

class ReporteScreen extends ConsumerWidget {
  final CultivoModel cultivo;
  const ReporteScreen({super.key, required this.cultivo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actividades = ref.watch(actividadProvider(cultivo.id));
    final novedades = ref.watch(novedadProvider(cultivo.id));
    final produccion = ref.watch(produccionProvider(cultivo.id));

    final tieneDatos = actividades.isNotEmpty ||
        novedades.isNotEmpty ||
        produccion.isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.fondo,
      appBar: AppBar(
        backgroundColor: AppTheme.azul,
        title: const Text('Reporte del Cultivo',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: tieneDatos
          ? _buildReporte(context, actividades, novedades, produccion)
          : const _SinDatos(),
    );
  }

  Widget _buildReporte(
    BuildContext context,
    List<ActividadModel> actividades,
    List<NovedadModel> novedades,
    List<ProduccionModel> produccion,
  ) {
    // Totales producción
    final totalesProduccion = <String, double>{};
    for (final r in produccion) {
      totalesProduccion[r.unidad] =
          (totalesProduccion[r.unidad] ?? 0) + r.cantidad;
    }

    // Conteo de actividades por tipo
    final actPorTipo = <String, int>{};
    for (final a in actividades) {
      actPorTipo[a.tipo] = (actPorTipo[a.tipo] ?? 0) + 1;
    }

    // Conteo de novedades por estado
    final novCriticas =
        novedades.where((n) => n.estado == 'Crítico').length;
    final novAtencion =
        novedades.where((n) => n.estado == 'Atención').length;
    final novNormales =
        novedades.where((n) => n.estado == 'Normal').length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Encabezado del reporte ────────────────────────────────────
        _SeccionEncabezado(cultivo: cultivo),
        const SizedBox(height: 16),

        // ── Resumen general ───────────────────────────────────────────
        _TarjetaResumen(
          actividades: actividades.length,
          novedades: novedades.length,
          cosechas: produccion.length,
          novCriticas: novCriticas,
        ),
        const SizedBox(height: 16),

        // ── Actividades ───────────────────────────────────────────────
        if (actividades.isNotEmpty) ...[
          _EncabezadoSeccion(
            icono: Icons.task_alt,
            titulo: 'Actividades realizadas',
            cantidad: actividades.length,
            color: AppTheme.verde,
          ),
          const SizedBox(height: 8),
          _SeccionActividades(
              actividades: actividades, actPorTipo: actPorTipo),
          const SizedBox(height: 16),
        ],

        // ── Novedades ─────────────────────────────────────────────────
        if (novedades.isNotEmpty) ...[
          _EncabezadoSeccion(
            icono: Icons.monitor_heart,
            titulo: 'Estado del cultivo',
            cantidad: novedades.length,
            color: AppTheme.tierra,
          ),
          const SizedBox(height: 8),
          _SeccionNovedades(
            novedades: novedades,
            normales: novNormales,
            atencion: novAtencion,
            criticas: novCriticas,
          ),
          const SizedBox(height: 16),
        ],

        // ── Producción ────────────────────────────────────────────────
        if (produccion.isNotEmpty) ...[
          _EncabezadoSeccion(
            icono: Icons.agriculture,
            titulo: 'Producción obtenida',
            cantidad: produccion.length,
            color: const Color(0xFF4E342E),
          ),
          const SizedBox(height: 8),
          _SeccionProduccion(
              produccion: produccion, totales: totalesProduccion),
          const SizedBox(height: 16),
        ],

        const SizedBox(height: 8),
        // Pie de reporte
        Center(
          child: Text(
            'Reporte generado el ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ── Sin datos ─────────────────────────────────────────────────────────────────
class _SinDatos extends StatelessWidget {
  const _SinDatos();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('📊', style: TextStyle(fontSize: 56)),
            SizedBox(height: 12),
            Text('Sin datos suficientes',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    fontSize: 17)),
            SizedBox(height: 8),
            Text(
              'Registra actividades, novedades o cosechas\npara generar el reporte del cultivo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Encabezado con datos del cultivo ─────────────────────────────────────────
class _SeccionEncabezado extends StatelessWidget {
  final CultivoModel cultivo;
  const _SeccionEncabezado({required this.cultivo});

  @override
  Widget build(BuildContext context) {
    final siembra = cultivo.fechaSiembra;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: AppTheme.verde.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('📊', style: TextStyle(fontSize: 24)),
              SizedBox(width: 10),
              Text('Reporte del Cultivo',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(color: Colors.white24, height: 20),
          _datoFila('Variedad', cultivo.tipo),
          _datoFila('Ubicación', cultivo.ubicacion),
          _datoFila('Área', '${cultivo.areHectareas} ha'),
          _datoFila(
              'Siembra',
              '${siembra.day}/${siembra.month}/${siembra.year}'),
          _datoFila('Etapa', cultivo.etapaCultivo),
          if (cultivo.altitud > 0)
            _datoFila('Altitud', '${cultivo.altitud.toStringAsFixed(0)} m.s.n.m.'),
        ],
      ),
    );
  }

  Widget _datoFila(String label, String valor) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              child: Text('$label:',
                  style: const TextStyle(
                      color: Colors.white60, fontSize: 12)),
            ),
            Expanded(
              child: Text(valor,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      );
}

// ── Tarjeta resumen de conteos ────────────────────────────────────────────────
class _TarjetaResumen extends StatelessWidget {
  final int actividades;
  final int novedades;
  final int cosechas;
  final int novCriticas;

  const _TarjetaResumen({
    required this.actividades,
    required this.novedades,
    required this.cosechas,
    required this.novCriticas,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Resumen general',
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            children: [
              _ConteoItem(
                  emoji: '✅',
                  label: 'Actividades',
                  valor: actividades,
                  color: AppTheme.verde),
              _ConteoItem(
                  emoji: '📋',
                  label: 'Novedades',
                  valor: novedades,
                  color: AppTheme.tierra),
              _ConteoItem(
                  emoji: '☕',
                  label: 'Cosechas',
                  valor: cosechas,
                  color: const Color(0xFF4E342E)),
              if (novCriticas > 0)
                _ConteoItem(
                    emoji: '🚨',
                    label: 'Críticas',
                    valor: novCriticas,
                    color: AppTheme.rojo),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConteoItem extends StatelessWidget {
  final String emoji;
  final String label;
  final int valor;
  final Color color;

  const _ConteoItem(
      {required this.emoji,
      required this.label,
      required this.valor,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text('$valor',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color)),
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}

// ── Encabezado de sección ─────────────────────────────────────────────────────
class _EncabezadoSeccion extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final int cantidad;
  final Color color;

  const _EncabezadoSeccion({
    required this.icono,
    required this.titulo,
    required this.cantidad,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icono, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Text(titulo,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14, color: color)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('$cantidad registros',
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

// ── Sección actividades ───────────────────────────────────────────────────────
class _SeccionActividades extends StatelessWidget {
  final List<ActividadModel> actividades;
  final Map<String, int> actPorTipo;

  const _SeccionActividades(
      {required this.actividades, required this.actPorTipo});

  @override
  Widget build(BuildContext context) {
    final ultimas = actividades.take(5).toList();
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          // Distribución por tipo
          if (actPorTipo.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: actPorTipo.entries
                    .map((e) => Chip(
                          label: Text('${e.key}: ${e.value}',
                              style: const TextStyle(fontSize: 12)),
                          backgroundColor:
                              AppTheme.verde.withValues(alpha: 0.1),
                          side: BorderSide(
                              color:
                                  AppTheme.verde.withValues(alpha: 0.3)),
                        ))
                    .toList(),
              ),
            ),
          const Divider(height: 1),
          // Últimas 5 actividades
          ...ultimas.map((a) => _FilaSimple(
                icono: Icons.task_alt,
                color: AppTheme.verde,
                titulo: a.tipo,
                subtitulo:
                    '${a.fecha.day}/${a.fecha.month}/${a.fecha.year}${a.notas.isNotEmpty ? ' · ${a.notas}' : ''}',
              )),
          if (actividades.length > 5)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                '+ ${actividades.length - 5} actividades más',
                style: const TextStyle(
                    color: AppTheme.verde, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Sección novedades ─────────────────────────────────────────────────────────
class _SeccionNovedades extends StatelessWidget {
  final List<NovedadModel> novedades;
  final int normales;
  final int atencion;
  final int criticas;

  const _SeccionNovedades({
    required this.novedades,
    required this.normales,
    required this.atencion,
    required this.criticas,
  });

  @override
  Widget build(BuildContext context) {
    final ultimas = novedades.take(5).toList();
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          // Barra de estado
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                if (normales > 0)
                  _BadgeEstado(
                      texto: '✅ Normal: $normales',
                      color: AppTheme.verde),
                if (atencion > 0) ...[
                  const SizedBox(width: 8),
                  _BadgeEstado(
                      texto: '⚠️ Atención: $atencion',
                      color: AppTheme.naranja),
                ],
                if (criticas > 0) ...[
                  const SizedBox(width: 8),
                  _BadgeEstado(
                      texto: '🚨 Crítico: $criticas',
                      color: AppTheme.rojo),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          ...ultimas.map((n) => _FilaSimple(
                icono: Icons.monitor_heart,
                color: AppTheme.tierra,
                titulo: '${n.tipo} · ${n.estado}',
                subtitulo:
                    '${n.fecha.day}/${n.fecha.month}/${n.fecha.year} · ${n.descripcion}',
              )),
          if (novedades.length > 5)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                '+ ${novedades.length - 5} novedades más',
                style: const TextStyle(
                    color: AppTheme.tierra, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

class _BadgeEstado extends StatelessWidget {
  final String texto;
  final Color color;
  const _BadgeEstado({required this.texto, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(texto,
          style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold)),
    );
  }
}

// ── Sección producción ────────────────────────────────────────────────────────
class _SeccionProduccion extends StatelessWidget {
  final List<ProduccionModel> produccion;
  final Map<String, double> totales;

  const _SeccionProduccion(
      {required this.produccion, required this.totales});

  @override
  Widget build(BuildContext context) {
    final ultimas = produccion.take(5).toList();
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          // Totales
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: totales.entries
                  .map((e) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4E342E)
                              .withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFF4E342E)
                                  .withValues(alpha: 0.25)),
                        ),
                        child: Text(
                          'Total: ${e.value.toStringAsFixed(1)} ${e.key}',
                          style: const TextStyle(
                              color: Color(0xFF4E342E),
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const Divider(height: 1),
          ...ultimas.map((p) => _FilaSimple(
                icono: Icons.agriculture,
                color: const Color(0xFF4E342E),
                titulo:
                    '${p.cantidad.toStringAsFixed(1)} ${p.unidad}',
                subtitulo:
                    '${p.fechaCosecha.day}/${p.fechaCosecha.month}/${p.fechaCosecha.year}${p.notas.isNotEmpty ? ' · ${p.notas}' : ''}',
              )),
          if (produccion.length > 5)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                '+ ${produccion.length - 5} cosechas más',
                style: const TextStyle(
                    color: Color(0xFF4E342E), fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Fila genérica ─────────────────────────────────────────────────────────────
class _FilaSimple extends StatelessWidget {
  final IconData icono;
  final Color color;
  final String titulo;
  final String subtitulo;

  const _FilaSimple({
    required this.icono,
    required this.color,
    required this.titulo,
    required this.subtitulo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icono, color: color, size: 15),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Text(subtitulo,
                    style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
