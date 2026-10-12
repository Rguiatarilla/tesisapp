import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../theme/app_theme.dart';

const double _lat = 1.1167;
const double _lon = -77.3833;

class ClimaScreen extends StatefulWidget {
  const ClimaScreen({super.key});

  @override
  State<ClimaScreen> createState() => _ClimaScreenState();
}

class _ClimaScreenState extends State<ClimaScreen> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _actual;
  List<Map<String, dynamic>> _pronostico = [];
  bool _cargando = true;
  String? _error;
  DateTime? _ultimaSync;
  late AnimationController _animCtrl;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -6, end: 6)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut));
    _cargar();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() { _cargando = true; _error = null; });
    try {
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$_lat&longitude=$_lon'
        '&current=temperature_2m,relative_humidity_2m,precipitation_probability,weathercode,windspeed_10m'
        '&daily=weathercode,temperature_2m_max,temperature_2m_min,precipitation_probability_max'
        '&timezone=America%2FBogota&forecast_days=6',
      );
      final res = await http.get(url).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final daily = body['daily'];
        final fechas = daily['time'] as List;
        final codes = daily['weathercode'] as List;
        final tmax = daily['temperature_2m_max'] as List;
        final tmin = daily['temperature_2m_min'] as List;
        final probs = daily['precipitation_probability_max'] as List;

        final pronostico = <Map<String, dynamic>>[];
        for (int i = 0; i < fechas.length && i < 6; i++) {
          pronostico.add({
            'fecha': fechas[i],
            'code': (codes[i] as num?)?.toInt() ?? 0,
            'tmax': (tmax[i] as num?)?.toDouble() ?? 0,
            'tmin': (tmin[i] as num?)?.toDouble() ?? 0,
            'prob': (probs[i] as num?)?.toInt() ?? 0,
          });
        }

        setState(() {
          _actual = body['current'];
          _pronostico = pronostico;
          _ultimaSync = DateTime.now();
          _cargando = false;
        });
      } else {
        setState(() { _error = 'Error al obtener datos'; _cargando = false; });
      }
    } catch (_) {
      setState(() { _error = 'Sin conexión a Internet'; _cargando = false; });
    }
  }

  static _ClimaInfo _infoClima(int code) {
    if (code == 0) return _ClimaInfo('Despejado', '☀️', const Color(0xFFF57F17), const Color(0xFFE65100));
    if (code <= 2) return _ClimaInfo('Poco nublado', '🌤️', const Color(0xFF1565C0), const Color(0xFF0D47A1));
    if (code <= 3) return _ClimaInfo('Nublado', '⛅', const Color(0xFF546E7A), const Color(0xFF37474F));
    if (code <= 48) return _ClimaInfo('Niebla', '🌫️', const Color(0xFF546E7A), const Color(0xFF37474F));
    if (code <= 55) return _ClimaInfo('Llovizna', '🌦️', const Color(0xFF0277BD), const Color(0xFF01579B));
    if (code <= 67) return _ClimaInfo('Lluvia', '🌧️', const Color(0xFF0D47A1), const Color(0xFF1A237E));
    if (code <= 77) return _ClimaInfo('Nieve', '🌨️', const Color(0xFF00838F), const Color(0xFF006064));
    if (code <= 82) return _ClimaInfo('Chubascos', '🌦️', const Color(0xFF00838F), const Color(0xFF004D40));
    return _ClimaInfo('Tormenta', '⛈️', const Color(0xFF1A237E), const Color(0xFF0D0D2B));
  }

  static String _nombreDia(String fechaStr, int index) {
    if (index == 0) return 'Hoy';
    if (index == 1) return 'Mañana';
    final fecha = DateTime.parse(fechaStr);
    const dias = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
    return dias[fecha.weekday % 7];
  }

  void _mostrarPronostico() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PronosticoSheet(pronostico: _pronostico, infoClima: _infoClima, nombreDia: _nombreDia),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.fondo,
      appBar: AppBar(
        backgroundColor: AppTheme.azul,
        title: const Text('Clima'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargar),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: AppTheme.azul))
          : _error != null
              ? _buildError()
              : _buildContenido(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📡', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 15)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _cargar,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.azul),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContenido() {
    final code = (_actual?['weathercode'] as num?)?.toInt() ?? 0;
    final info = _infoClima(code);
    final temp = (_actual?['temperature_2m'] as num?)?.toDouble() ?? 0;
    final humedad = (_actual?['relative_humidity_2m'] as num?)?.toInt() ?? 0;
    final lluvia = (_actual?['precipitation_probability'] as num?)?.toInt() ?? 0;
    final viento = (_actual?['windspeed_10m'] as num?)?.toDouble() ?? 0;

    return SingleChildScrollView(
      child: Column(
        children: [
          // ── Header con tarjeta glassmorphism ──────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [info.colorOscuro, info.colorPrincipal],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                // Ubicación y hora
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on, color: Colors.redAccent, size: 14),
                    SizedBox(width: 4),
                    Text('Yacuanquer, Nariño',
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
                if (_ultimaSync != null)
                  Text(
                    'Actualizado: ${_ultimaSync!.hour}:${_ultimaSync!.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                const SizedBox(height: 20),

                // Tarjeta glassmorphism
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      // Ilustración animada
                      AnimatedBuilder(
                        animation: _floatAnim,
                        builder: (_, __) => Transform.translate(
                          offset: Offset(0, _floatAnim.value),
                          child: _NubeIlustracion(code: code, size: 90),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${temp.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 56, fontWeight: FontWeight.bold, height: 1),
                      ),
                      const SizedBox(height: 4),
                      Text(info.descripcion,
                          style: const TextStyle(color: Colors.white70, fontSize: 18)),
                      const SizedBox(height: 16),
                      // Botón pronóstico 5 días
                      GestureDetector(
                        onTap: _mostrarPronostico,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.calendar_month, color: Colors.white70, size: 16),
                              SizedBox(width: 6),
                              Text('Ver pronóstico 5 días',
                                  style: TextStyle(color: Colors.white, fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Datos actuales ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(children: [
                  Expanded(child: _DatoCard(emoji: '💧', label: 'Humedad', valor: '$humedad%')),
                  const SizedBox(width: 10),
                  Expanded(child: _DatoCard(emoji: '🌧️', label: 'Prob. lluvia', valor: '$lluvia%')),
                  const SizedBox(width: 10),
                  Expanded(child: _DatoCard(emoji: '💨', label: 'Viento', valor: '${viento.toStringAsFixed(1)}km/h')),
                ]),
                const SizedBox(height: 16),
                _RecomendacionCafe(probLluvia: lluvia, temp: temp),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ilustración de nube dibujada con Canvas ───────────────────────────────────
class _NubeIlustracion extends StatelessWidget {
  final int code;
  final double size;
  const _NubeIlustracion({required this.code, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size * 1.4, size),
      painter: _NubePainter(code: code),
    );
  }
}

class _NubePainter extends CustomPainter {
  final int code;
  _NubePainter({required this.code});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sombra
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Nube principal
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.9);
    final cloudPath = Path();
    cloudPath.addOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.55), width: w * 0.7, height: h * 0.45));
    cloudPath.addOval(Rect.fromCenter(center: Offset(w * 0.35, h * 0.48), width: w * 0.45, height: h * 0.38));
    cloudPath.addOval(Rect.fromCenter(center: Offset(w * 0.62, h * 0.42), width: w * 0.38, height: h * 0.35));

    canvas.drawPath(cloudPath, shadowPaint);
    canvas.drawPath(cloudPath, cloudPaint);

    // Sol (si despejado o poco nublado)
    if (code <= 2) {
      final sunPaint = Paint()..color = const Color(0xFFFDD835);
      canvas.drawCircle(Offset(w * 0.78, h * 0.22), h * 0.22, sunPaint);
      // Rayos
      final rayPaint = Paint()
        ..color = const Color(0xFFFDD835)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      for (int i = 0; i < 8; i++) {
        final angle = i * 3.14159 / 4;
        final cx = w * 0.78;
        final cy = h * 0.22;
        final r1 = h * 0.27;
        final r2 = h * 0.33;
        canvas.drawLine(
          Offset(cx + r1 * _cos(angle), cy + r1 * _sin(angle)),
          Offset(cx + r2 * _cos(angle), cy + r2 * _sin(angle)),
          rayPaint,
        );
      }
    }

    // Gotas de lluvia
    if (code >= 51) {
      final dropPaint = Paint()
        ..color = const Color(0xFF90CAF9)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      final drops = [
        [w * 0.3, h * 0.82, w * 0.28, h * 0.95],
        [w * 0.5, h * 0.85, w * 0.48, h * 0.98],
        [w * 0.7, h * 0.82, w * 0.68, h * 0.95],
        [w * 0.4, h * 0.9, w * 0.38, h * 1.03],
        [w * 0.6, h * 0.88, w * 0.58, h * 1.01],
      ];
      for (final d in drops) {
        canvas.drawLine(Offset(d[0], d[1]), Offset(d[2], d[3]), dropPaint);
      }
    }
  }

  double _cos(double a) => (a == 0) ? 1 : (a == 1.5708) ? 0 : (a == 3.14159) ? -1 : (a == 4.71239) ? 0 : _cosCalc(a);
  double _sin(double a) => (a == 0) ? 0 : (a == 1.5708) ? 1 : (a == 3.14159) ? 0 : (a == 4.71239) ? -1 : _sinCalc(a);
  double _cosCalc(double a) { double s = 0, t = 1; for (int i = 1; i <= 10; i++) { t *= -a * a / (2 * i * (2 * i - 1)); s += t; } return 1 + s; }
  double _sinCalc(double a) { double s = a, t = a; for (int i = 1; i <= 10; i++) { t *= -a * a / ((2 * i + 1) * (2 * i)); s += t; } return s; }

  @override
  bool shouldRepaint(_NubePainter old) => old.code != code;
}

// ── Bottom sheet pronóstico 5 días ────────────────────────────────────────────
class _PronosticoSheet extends StatelessWidget {
  final List<Map<String, dynamic>> pronostico;
  final _ClimaInfo Function(int) infoClima;
  final String Function(String, int) nombreDia;

  const _PronosticoSheet({
    required this.pronostico,
    required this.infoClima,
    required this.nombreDia,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.calendar_month, color: AppTheme.azul, size: 20),
                SizedBox(width: 8),
                Text('Pronóstico 5 días',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.azul)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.location_on, color: Colors.redAccent, size: 13),
                SizedBox(width: 3),
                Text('Yacuanquer, Nariño', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(pronostico.length > 5 ? 5 : pronostico.length, (i) {
            final d = pronostico[i];
            final code = d['code'] as int;
            final info = infoClima(code);
            final fecha = d['fecha'] as String;
            final dia = nombreDia(fecha, i);
            final fechaObj = DateTime.parse(fecha);
            final fechaStr = '${fechaObj.day}/${fechaObj.month}';
            final tmax = (d['tmax'] as double).toStringAsFixed(1);
            final tmin = (d['tmin'] as double).toStringAsFixed(1);
            final prob = d['prob'] as int;
            final esHoy = i == 0;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: esHoy ? AppTheme.azul.withValues(alpha: 0.08) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14),
                border: esHoy ? Border.all(color: AppTheme.azul.withValues(alpha: 0.3)) : null,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(dia,
                            style: TextStyle(
                                fontWeight: esHoy ? FontWeight.bold : FontWeight.w500,
                                fontSize: 14,
                                color: esHoy ? AppTheme.azul : Colors.black87)),
                        Text(fechaStr, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                  ),
                  Text(info.emoji, style: const TextStyle(fontSize: 26)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(info.descripcion,
                        style: const TextStyle(fontSize: 13, color: Colors.black54)),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('$tmax° / $tmin°',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: esHoy ? AppTheme.azul : Colors.black87)),
                      Row(
                        children: [
                          const Icon(Icons.water_drop, color: Colors.blueAccent, size: 11),
                          const SizedBox(width: 2),
                          Text('$prob%', style: const TextStyle(color: Colors.blueAccent, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ClimaInfo {
  final String descripcion;
  final String emoji;
  final Color colorPrincipal;
  final Color colorOscuro;
  _ClimaInfo(this.descripcion, this.emoji, this.colorPrincipal, this.colorOscuro);
}

class _DatoCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String valor;
  const _DatoCard({required this.emoji, required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(valor, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _RecomendacionCafe extends StatelessWidget {
  final int probLluvia;
  final double temp;
  const _RecomendacionCafe({required this.probLluvia, required this.temp});

  @override
  Widget build(BuildContext context) {
    late String emoji, titulo, mensaje;
    late Color color;

    if (probLluvia >= 70) {
      emoji = '⚠️'; titulo = 'Cuidado con el café'; color = Colors.orange.shade700;
      mensaje = 'Lluvia fuerte puede afectar la floración y causar enfermedades fungosas. Revisa el drenaje de tus lotes.';
    } else if (temp < 10) {
      emoji = '🥶'; titulo = 'Temperatura baja'; color = AppTheme.azul;
      mensaje = 'Temperatura baja puede afectar el desarrollo del grano. Evita labores de poda hoy.';
    } else if (probLluvia < 20 && temp > 28) {
      emoji = '🌵'; titulo = 'Riesgo de sequía'; color = AppTheme.naranja;
      mensaje = 'Poca lluvia y calor. Revisa la humedad del suelo y considera riego si es posible.';
    } else {
      emoji = '✅'; titulo = 'Buen día para el café'; color = AppTheme.verde;
      mensaje = 'Condiciones favorables. Puedes realizar labores de fertilización, deshierbe o cosecha.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
                const SizedBox(height: 4),
                Text(mensaje, style: const TextStyle(fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
