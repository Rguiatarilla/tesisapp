import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';

// ── Provider de preferencias de alertas ──────────────────────────────────────
class AlertaPreferencia {
  final String id;
  final String titulo;
  final String descripcion;
  final String emoji;
  bool activa;

  AlertaPreferencia({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.emoji,
    this.activa = true,
  });
}

class AlertasPrefsNotifier extends StateNotifier<List<AlertaPreferencia>> {
  AlertasPrefsNotifier()
      : super([
          AlertaPreferencia(id: 'cultivos', titulo: 'Actividades del cultivo', descripcion: 'Recordatorios de riego, fertilización y cosecha programadas.', emoji: '🌿'),
          AlertaPreferencia(id: 'precios', titulo: 'Precios de mercado', descripcion: 'Alertas cuando los precios del café cambien significativamente.', emoji: '💰'),
          AlertaPreferencia(id: 'clima', titulo: 'Clima y alertas', descripcion: 'Avisos de lluvia fuerte, frío y condiciones de riesgo para el cafetal.', emoji: '🌦️'),
          AlertaPreferencia(id: 'lunar', titulo: 'Fase lunar', descripcion: 'Notificación cuando cambia la fase lunar y hay recomendaciones para el café.', emoji: '🌙'),
          AlertaPreferencia(id: 'lluvia', titulo: 'Lluvia fuerte', descripcion: 'Aviso cuando se esperan lluvias intensas que puedan afectar el cafetal.', emoji: '🌧️'),
          AlertaPreferencia(id: 'viento', titulo: 'Viento fuerte', descripcion: 'Alerta cuando los vientos superen los 40 km/h.', emoji: '💨'),
          AlertaPreferencia(id: 'frio', titulo: 'Riesgo de frío', descripcion: 'Aviso cuando la temperatura baje de 8°C y pueda afectar la floración.', emoji: '🥶'),
          AlertaPreferencia(id: 'sembrar', titulo: 'Buen día para sembrar', descripcion: 'Aviso cuando la luna y el clima son favorables para sembrar colinos.', emoji: '🌱'),
          AlertaPreferencia(id: 'cosechar', titulo: 'Buen día para cosechar', descripcion: 'Recomendación cuando las condiciones son ideales para la cosecha del café.', emoji: '☕'),
          AlertaPreferencia(id: 'limpiar', titulo: 'Buen día para limpiar', descripcion: 'Aviso cuando la luna menguante favorece el deshierbe del cafetal.', emoji: '🌿'),
          AlertaPreferencia(id: 'push', titulo: 'Notificaciones push', descripcion: 'Recibe avisos en la barra de notificaciones del celular, aunque la app esté cerrada.', emoji: '🔔'),
          AlertaPreferencia(id: 'inapp', titulo: 'Alertas dentro de la app', descripcion: 'Muestra alertas y recomendaciones en la pantalla principal cuando abres la app.', emoji: '📱'),
        ]);

  void toggle(String id) {
    state = [
      for (final a in state)
        if (a.id == id)
          AlertaPreferencia(id: a.id, titulo: a.titulo, descripcion: a.descripcion, emoji: a.emoji, activa: !a.activa)
        else
          a,
    ];
  }

  void setAll(bool value) {
    state = [for (final a in state) AlertaPreferencia(id: a.id, titulo: a.titulo, descripcion: a.descripcion, emoji: a.emoji, activa: value)];
  }

  int get activas => state.where((a) => a.activa).length;
  int get total => state.length;
}

final alertasPrefsProvider = StateNotifierProvider<AlertasPrefsNotifier, List<AlertaPreferencia>>(
  (_) => AlertasPrefsNotifier(),
);

// ── Pantalla Ajustes de Alertas ───────────────────────────────────────────────
class AjustesAlertasScreen extends ConsumerWidget {
  const AjustesAlertasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(alertasPrefsProvider);
    final notifier = ref.read(alertasPrefsProvider.notifier);
    final activas = notifier.activas;
    final total = notifier.total;

    // Grupos
    final generales = prefs.where((p) => ['cultivos', 'precios', 'clima', 'lunar'].contains(p.id)).toList();
    final riesgo = prefs.where((p) => ['lluvia', 'viento', 'frio'].contains(p.id)).toList();
    final recomendaciones = prefs.where((p) => ['sembrar', 'cosechar', 'limpiar'].contains(p.id)).toList();
    final canales = prefs.where((p) => ['push', 'inapp'].contains(p.id)).toList();

    return Scaffold(
      backgroundColor: AppTheme.fondo,
      appBar: AppBar(
        backgroundColor: AppTheme.rojo,
        title: const Text('Ajustes de alertas'),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Preferencias guardadas'), backgroundColor: AppTheme.verde),
              );
              Navigator.pop(context);
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Resumen
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.rojo.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.rojo.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('🔔', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$activas de $total alertas activas',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const Text('Activa solo las que necesitas\npara tu cafetal',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => notifier.setAll(true),
                  child: const Text('Todas', style: TextStyle(color: AppTheme.verde, fontWeight: FontWeight.bold)),
                ),
                TextButton(
                  onPressed: () => notifier.setAll(false),
                  child: const Text('Ninguna', style: TextStyle(color: AppTheme.rojo, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _seccion('🌿  Avisos generales', generales, notifier),
          const SizedBox(height: 16),
          _seccion('⚠️  Alertas de riesgo', riesgo, notifier),
          const SizedBox(height: 16),
          _seccion('☕  Recomendaciones para el café', recomendaciones, notifier),
          const SizedBox(height: 16),
          _seccion('🔔  Canales de notificación', canales, notifier),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _seccion(String titulo, List<AlertaPreferencia> items, AlertasPrefsNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(titulo,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54)),
        ),
        ...items.map((p) => _AlertaTile(pref: p, notifier: notifier)),
      ],
    );
  }
}

class _AlertaTile extends ConsumerWidget {
  final AlertaPreferencia pref;
  final AlertasPrefsNotifier notifier;
  const _AlertaTile({required this.pref, required this.notifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.rojo.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text(pref.emoji, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pref.titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Text(pref.descripcion, style: const TextStyle(color: Colors.grey, fontSize: 11, height: 1.3)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: pref.activa,
            onChanged: (_) => notifier.toggle(pref.id),
            activeThumbColor: AppTheme.rojo,
            activeTrackColor: AppTheme.rojo.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}
