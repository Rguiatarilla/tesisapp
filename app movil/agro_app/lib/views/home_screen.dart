import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'cultivos/cultivos_screen.dart';
import 'clima/clima_screen.dart';
import 'lunar/lunar_screen.dart';
import 'precios/precios_screen.dart';
import 'alertas/alertas_screen.dart';
import 'alertas/ajustes_alertas_screen.dart';
import 'perfil/perfil_screen.dart';
import '../viewmodels/cultivo_viewmodel.dart';

const double _lat = 1.1167;
const double _lon = -77.3833;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Mini clima
  double? _temp;
  String _condicion = '';
  String _climaEmoji = '🌤️';
  bool _climaCargando = true;

  // Preview alertas
  List<_AlertaPreview> _alertasPreview = [];

  @override
  void initState() {
    super.initState();
    _cargarClima();
  }

  Future<void> _cargarClima() async {
    try {
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$_lat&longitude=$_lon'
        '&current=temperature_2m,weathercode,precipitation_probability'
        '&daily=precipitation_sum,precipitation_probability_max,temperature_2m_min,weathercode'
        '&timezone=America%2FBogota&forecast_days=3',
      );
      final res = await http.get(url).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final current = body['current'];
        final daily = body['daily'];
        final code = (current['weathercode'] as num?)?.toInt() ?? 0;
        final temp = (current['temperature_2m'] as num?)?.toDouble() ?? 0;

        // Generar alertas preview
        final alertas = <_AlertaPreview>[];
        final fechas = daily['time'] as List;
        final lluvias = daily['precipitation_sum'] as List;
        final probs = daily['precipitation_probability_max'] as List;
        final tempMins = daily['temperature_2m_min'] as List;
        final dias = ['Hoy', 'Mañana', 'Pasado mañana'];

        for (int i = 0; i < fechas.length && alertas.length < 2; i++) {
          final lluvia = (lluvias[i] as num?)?.toDouble() ?? 0;
          final prob = (probs[i] as num?)?.toInt() ?? 0;
          final tmin = (tempMins[i] as num?)?.toDouble() ?? 20;
          final dia = dias[i];

          if (lluvia > 10 || prob >= 60) {
            alertas.add(_AlertaPreview(
              letra: 'L',
              color: AppTheme.rojo,
              titulo: '${dia == 'Hoy' ? 'Hoy' : dia} va a llover fuerte',
              subtitulo: 'Evita fumigar o fertilizar',
              tipo: 'lluvia',
            ));
          }
          if (tmin < 8) {
            alertas.add(_AlertaPreview(
              letra: 'F',
              color: AppTheme.azul,
              titulo: '$dia riesgo de frío',
              subtitulo: 'Protege tus cultivos esta noche',
              tipo: 'frio',
            ));
          }
        }

        // Fase lunar para hoy
        final faseHoy = _calcularFaseNombre(DateTime.now());
        if (alertas.length < 2) {
          alertas.add(_AlertaPreview(
            letra: faseHoy.$2,
            color: AppTheme.morado,
            titulo: faseHoy.$1,
            subtitulo: faseHoy.$3,
            tipo: 'lunar',
          ));
        }

        if (mounted) {
          setState(() {
            _temp = temp;
            _condicion = _condicionClima(code);
            _climaEmoji = _emojiClima(code);
            _climaCargando = false;
            _alertasPreview = alertas.take(2).toList();
          });
        }
      } else {
        if (mounted) setState(() => _climaCargando = false);
      }
    } catch (_) {
      if (mounted) setState(() => _climaCargando = false);
    }
  }

  static String _condicionClima(int code) {
    if (code == 0) return 'Despejado';
    if (code <= 2) return 'Poco nublado';
    if (code <= 3) return 'Nublado';
    if (code <= 48) return 'Niebla';
    if (code <= 55) return 'Llovizna';
    if (code <= 67) return 'Lluvia';
    if (code <= 77) return 'Nieve';
    if (code <= 82) return 'Chubascos';
    return 'Tormenta';
  }

  static String _emojiClima(int code) {
    if (code == 0) return '☀️';
    if (code <= 2) return '🌤️';
    if (code <= 3) return '⛅';
    if (code <= 48) return '🌫️';
    if (code <= 67) return '🌧️';
    return '⛈️';
  }

  static (String, String, String) _calcularFaseNombre(DateTime fecha) {
    final ref = DateTime(2000, 1, 6);
    final diff = fecha.difference(ref).inDays;
    const ciclo = 29.53058867;
    final fase = (diff % ciclo + ciclo) % ciclo;
    if (fase < 1.85) return ('Luna Nueva', 'N', 'Buen momento para abonar');
    if (fase < 9.22) return ('Luna Creciente', 'C', 'Ideal para sembrar colinos');
    if (fase < 16.61) return ('Luna Llena', 'LL', 'Excelente para cosechar');
    return ('Luna Menguante', 'M', 'Perfecto para deshierbe');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final hora = DateTime.now().hour;
    final saludo = hora < 12 ? 'Buenos días,' : hora < 18 ? 'Buenas tardes,' : 'Buenas noches,';

    return Scaffold(
      backgroundColor: AppTheme.fondo,
      body: CustomScrollView(
        slivers: [
          // ── Header verde ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 150,
            pinned: true,
            backgroundColor: AppTheme.verde,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.settings, color: Colors.white, size: 18),
                ),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AjustesAlertasScreen())),
              ),
              IconButton(
                icon: const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person_outline, color: Colors.white, size: 18),
                ),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PerfilScreen())),
              ),
              IconButton(
                icon: const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.logout, color: Colors.white, size: 18),
                ),
                onPressed: () => ref.read(authProvider.notifier).logout(),
              ),
              const SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 48, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(saludo,
                            style: const TextStyle(color: Colors.white70, fontSize: 15)),
                        Text(
                          user?.nombre ?? '',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.landscape, color: Colors.white60, size: 14),
                          const SizedBox(width: 4),
                          Text('Finca ${user?.nombreFinca ?? ''}',
                              style: const TextStyle(color: Colors.white60, fontSize: 13)),
                        ]),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Fila: Mis Cultivos + Mini Clima ───────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tarjeta Mis Cultivos
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(
                              builder: (_) => CultivosScreen(usuarioNombre: user?.nombre ?? ''))),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.verde.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.grass, color: AppTheme.verde, size: 22),
                                    ),
                                    const Text('🌿', style: TextStyle(fontSize: 28)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Text('Mis Cultivos',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.verde)),
                                const SizedBox(height: 4),
                                const Text('Registra y gestiona tus cultivos',
                                    style: TextStyle(fontSize: 11, color: Colors.grey)),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppTheme.verde.withValues(alpha: 0.4)),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text('Ver mis cultivos →',
                                      style: TextStyle(fontSize: 11, color: AppTheme.verde, fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Mini tarjeta clima
                      GestureDetector(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const ClimaScreen())),
                        child: Container(
                          width: 140,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF37474F), Color(0xFF546E7A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 10)],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.location_on, color: Colors.redAccent, size: 12),
                                  SizedBox(width: 2),
                                  Text('Yacuanquer',
                                      style: TextStyle(color: Colors.white70, fontSize: 10)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _climaCargando
                                  ? const SizedBox(
                                      height: 40,
                                      child: Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
                                  : Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(_climaEmoji, style: const TextStyle(fontSize: 32)),
                                        Text(
                                          _temp != null ? '${_temp!.toStringAsFixed(1)}°C' : '--',
                                          style: const TextStyle(
                                              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                                        ),
                                        Text(_condicion,
                                            style: const TextStyle(color: Colors.white70, fontSize: 11)),
                                      ],
                                    ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.calendar_today, color: Colors.white70, size: 10),
                                    SizedBox(width: 3),
                                    Text('5 días', style: TextStyle(color: Colors.white70, fontSize: 10)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Tarjeta Alertas preview ────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)],
                    ),
                    child: Column(
                      children: [
                        // Cabecera
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: AppTheme.rojo.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.notifications_active, color: AppTheme.rojo, size: 18),
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text('Alertas y Recomendaciones',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              ),
                              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        // Items
                        ..._alertasPreview.map((a) => _AlertaPreviewTile(alerta: a)),
                        if (_alertasPreview.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('Sin alertas activas', style: TextStyle(color: Colors.grey)),
                          ),
                        // Botón ver todas
                        InkWell(
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const AlertasScreen())),
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(top: BorderSide(color: Colors.grey.shade100)),
                            ),
                            child: const Center(
                              child: Text(
                                '→  Ver todas las alertas',
                                style: TextStyle(
                                    color: AppTheme.rojo, fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Accesos rápidos ────────────────────────────────────
                  const Text('Accesos rápidos',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _AccesoRapido(
                        emoji: '🌙',
                        label: 'Fase Lunar',
                        color: AppTheme.morado,
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const LunarScreen())),
                      ),
                      _AccesoRapido(
                        emoji: '💰',
                        label: 'Precios',
                        color: AppTheme.naranja,
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const PreciosScreen())),
                      ),
                      _AccesoRapido(
                        emoji: '⚠️',
                        label: 'Alertas',
                        color: AppTheme.rojo,
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const AlertasScreen())),
                      ),
                      _AccesoRapido(
                        emoji: '🌤️',
                        label: 'Clima',
                        color: AppTheme.azul,
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const ClimaScreen())),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // ── Segunda fila de accesos ────────────────────────────
                  _TarjetaAccesosSecundarios(usuarioNombre: user?.nombre ?? ''),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertaPreview {
  final String letra;
  final Color color;
  final String titulo;
  final String subtitulo;
  final String tipo;
  _AlertaPreview({required this.letra, required this.color, required this.titulo, required this.subtitulo, required this.tipo});
}

class _AlertaPreviewTile extends StatelessWidget {
  final _AlertaPreview alerta;
  const _AlertaPreviewTile({required this.alerta});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: alerta.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: alerta.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(alerta.letra,
                  style: TextStyle(color: alerta.color, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alerta.titulo,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(alerta.subtitulo,
                    style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccesoRapido extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _AccesoRapido({required this.emoji, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
        ],
      ),
    );
  }
}

// ── Tarjeta de accesos secundarios (Seguimiento, Producción, Novedades, Reporte)
class _TarjetaAccesosSecundarios extends ConsumerWidget {
  final String usuarioNombre;
  const _TarjetaAccesosSecundarios({required this.usuarioNombre});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cultivos = ref.watch(cultivoProvider(usuarioNombre));
    final primero = cultivos.isNotEmpty ? cultivos.first : null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              'Gestión del cultivo',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54),
            ),
          ),
          Row(
            children: [
              _SecundarioBtn(
                emoji: '📅',
                label: 'Actividades',
                color: AppTheme.verde,
                bloqueado: primero == null,
                onTap: primero == null
                    ? () => _sinCultivo(context)
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CultivosScreen(usuarioNombre: usuarioNombre),
                          ),
                        ),
              ),
              _SecundarioBtn(
                emoji: '📋',
                label: 'Novedades',
                color: AppTheme.tierra,
                bloqueado: primero == null,
                onTap: primero == null
                    ? () => _sinCultivo(context)
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CultivosScreen(usuarioNombre: usuarioNombre),
                          ),
                        ),
              ),
              _SecundarioBtn(
                emoji: '☕',
                label: 'Producción',
                color: const Color(0xFF4E342E),
                bloqueado: primero == null,
                onTap: primero == null
                    ? () => _sinCultivo(context)
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CultivosScreen(usuarioNombre: usuarioNombre),
                          ),
                        ),
              ),
              _SecundarioBtn(
                emoji: '📊',
                label: 'Reportes',
                color: AppTheme.azul,
                bloqueado: primero == null,
                onTap: primero == null
                    ? () => _sinCultivo(context)
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CultivosScreen(usuarioNombre: usuarioNombre),
                          ),
                        ),
              ),
            ],
          ),
          if (primero == null)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                '⬆️ Registra un cultivo para acceder a estas funciones',
                style: TextStyle(fontSize: 11, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  void _sinCultivo(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Primero registra un cultivo en "Mis Cultivos"'),
        backgroundColor: AppTheme.verde,
      ),
    );
  }
}

class _SecundarioBtn extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final bool bloqueado;
  final VoidCallback onTap;

  const _SecundarioBtn({
    required this.emoji,
    required this.label,
    required this.color,
    required this.bloqueado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Opacity(
          opacity: bloqueado ? 0.4 : 1.0,
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
                Text(emoji, style: const TextStyle(fontSize: 20)),
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
      ),
    );
  }
}
