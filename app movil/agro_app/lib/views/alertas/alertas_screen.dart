import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../theme/app_theme.dart';
import 'ajustes_alertas_screen.dart';

const double _lat = 1.1167;
const double _lon = -77.3833;

class AlertasScreen extends StatefulWidget {
  const AlertasScreen({super.key});

  @override
  State<AlertasScreen> createState() => _AlertasScreenState();
}

class _AlertasScreenState extends State<AlertasScreen> {
  List<_Alerta> _alertas = [];
  List<_SaberCombinado> _saberes = [];
  bool _cargando = true;
  String? _error;
  DateTime? _ultimaSync;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  static String _faseId(DateTime fecha) {
    final ref = DateTime(2000, 1, 6);
    final diff = fecha.difference(ref).inDays;
    const ciclo = 29.53058867;
    final fase = (diff % ciclo + ciclo) % ciclo;
    if (fase < 1.85) return 'nueva';
    if (fase < 9.22) return 'creciente';
    if (fase < 16.61) return 'llena';
    if (fase < 23.99) return 'menguante';
    return 'nueva';
  }

  Future<void> _cargar() async {
    setState(() { _cargando = true; _error = null; });
    try {
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$_lat&longitude=$_lon'
        '&daily=precipitation_sum,precipitation_probability_max,windspeed_10m_max,'
        'temperature_2m_min,temperature_2m_max,weathercode'
        '&timezone=America%2FBogota&forecast_days=3',
      );
      final res = await http.get(url).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final daily = jsonDecode(res.body)['daily'];
        final alertas = <_Alerta>[];
        final fechas = daily['time'] as List;
        final lluvias = daily['precipitation_sum'] as List;
        final probs = daily['precipitation_probability_max'] as List;
        final vientos = daily['windspeed_10m_max'] as List;
        final tempMin = daily['temperature_2m_min'] as List;
        final dias = ['Hoy', 'Mañana', 'Pasado mañana'];

        for (int i = 0; i < fechas.length; i++) {
          final lluvia = (lluvias[i] as num?)?.toDouble() ?? 0;
          final prob = (probs[i] as num?)?.toInt() ?? 0;
          final viento = (vientos[i] as num?)?.toDouble() ?? 0;
          final tmin = (tempMin[i] as num?)?.toDouble() ?? 20;
          final dia = dias[i];
          final fecha = DateTime.parse(fechas[i]);
          final fase = _faseId(fecha);

          // Alerta de lluvia
          if (lluvia > 5 || prob >= 60) {
            alertas.add(_Alerta(
              letra: 'L',
              color: AppTheme.rojo,
              titulo: '$dia va a llover fuerte',
              subtitulo: '${lluvia.toStringAsFixed(0)} mm, $prob% probabilidad. Evita fumigar.',
              tipo: _TipoAlerta.alerta,
            ));
          }

          // Fase lunar (solo mañana)
          if (i == 1) {
            final (faseNombre, faseLetra, faseColor, faseMsg) = _datosFase(fase);
            alertas.add(_Alerta(
              letra: faseLetra,
              color: faseColor,
              titulo: 'Mañana: $faseNombre',
              subtitulo: faseMsg,
              tipo: _TipoAlerta.lunar,
            ));
          }

          // Viento
          if (viento > 40) {
            alertas.add(_Alerta(
              letra: 'V',
              color: AppTheme.azul,
              titulo: '$dia hay viento fuerte',
              subtitulo: 'Vientos de hasta ${viento.toStringAsFixed(0)} km/h.',
              tipo: _TipoAlerta.precaucion,
            ));
          }

          // Frío
          if (tmin < 8) {
            alertas.add(_Alerta(
              letra: 'F',
              color: const Color(0xFF0288D1),
              titulo: '$dia riesgo de frío',
              subtitulo: 'Temperatura mínima ${tmin.toStringAsFixed(1)}°C. Protege la floración.',
              tipo: _TipoAlerta.alerta,
            ));
          }
        }

        // Saberes combinados según fase actual
        final faseActual = _faseId(DateTime.now());
        final saberes = _generarSaberes(faseActual);

        setState(() {
          _alertas = alertas;
          _saberes = saberes;
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

  static (String, String, Color, String) _datosFase(String fase) {
    switch (fase) {
      case 'nueva':
        return ('Luna Nueva', 'N', AppTheme.morado,
            'La tierra está receptiva. Aplica abono orgánico (pulpa de café, ceniza). Ideal para preparar semilleros y planificar labores del mes.');
      case 'creciente':
        return ('Luna Creciente', 'C', const Color(0xFF4527A0),
            'La savia sube con fuerza. Ideal para sembrar colinos y hacer trasplantes.');
      case 'llena':
        return ('Luna Llena', 'LL', const Color(0xFFF57F17),
            'Los granos tienen mayor peso. Excelente para cosechar. Evita la siembra.');
      default:
        return ('Luna Menguante', 'M', const Color(0xFF37474F),
            'Perfecto para deshierbe y control de plagas. Lo que se corta no vuelve tan pronto.');
    }
  }

  static List<_SaberCombinado> _generarSaberes(String fase) {
    switch (fase) {
      case 'nueva':
        return [
          _SaberCombinado(emoji: '🌑', titulo: 'Luna Nueva: momento de abonar',
              detalle: 'La tierra está en su punto más receptivo. Aplica pulpa de café compostada, ceniza de madera y cal dolomita. Los nutrientes se absorben con mayor eficiencia en esta fase.'),
          _SaberCombinado(emoji: '🪱', titulo: 'Activa la vida del suelo',
              detalle: 'Luna nueva es ideal para aplicar bioinsumos y lombricompuesto. Los microorganismos del suelo están más activos y descomponen la materia orgánica más rápido.'),
        ];
      case 'creciente':
        return [
          _SaberCombinado(emoji: '🌱', titulo: 'Siembra en luna creciente',
              detalle: 'La savia del café sube con fuerza hacia las ramas y hojas. Las plantas sembradas en esta fase echan raíz más rápido y tienen mayor vigor inicial.'),
          _SaberCombinado(emoji: '💧', titulo: 'Fertilización foliar',
              detalle: 'La luna creciente favorece la absorción de nutrientes por las hojas. Aplica fertilizantes foliares en la mañana temprano para mejores resultados.'),
        ];
      case 'llena':
        return [
          _SaberCombinado(emoji: '☕', titulo: 'Cosecha en luna llena',
              detalle: 'Los granos de café alcanzan su mayor peso y contenido de azúcares en luna llena. Los caficultores de Yacuanquer siempre cosechaban en esta fase para obtener mejor calidad en taza.'),
          _SaberCombinado(emoji: '🌿', titulo: 'Evita la siembra hoy',
              detalle: 'En luna llena la savia está muy activa y las plantas trasplantadas sufren más estrés. Espera a la fase creciente para hacer trasplantes o siembras.'),
        ];
      default:
        return [
          _SaberCombinado(emoji: '🌿', titulo: 'Deshierbe en luna menguante',
              detalle: 'Las malezas arrancadas en luna menguante tardan más en rebrotar porque la savia baja hacia las raíces. Es el mejor momento para el control manual de malezas en el cafetal.'),
          _SaberCombinado(emoji: '🔪', titulo: 'Podas y deschuponada',
              detalle: 'La luna menguante es ideal para podas porque las heridas cicatrizan más rápido y hay menos riesgo de enfermedades fungosas. Realiza la deschuponada y poda de ramas improductivas.'),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.fondo,
      appBar: AppBar(
        backgroundColor: AppTheme.rojo,
        title: const Text('Alertas y Recomendaci...'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AjustesAlertasScreen())),
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargar),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: AppTheme.rojo))
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
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _cargar,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.rojo),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContenido() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Hora de actualización
        if (_ultimaSync != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Actualizado: ${_ultimaSync!.hour}:${_ultimaSync!.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

        // Lista de alertas
        if (_alertas.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: const Column(
              children: [
                Text('✅', style: TextStyle(fontSize: 40)),
                SizedBox(height: 8),
                Text('Sin alertas activas', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Todo tranquilo por ahora', style: TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          )
        else
          ..._alertas.map((a) => _AlertaTile(alerta: a)),

        const SizedBox(height: 20),

        // Sección Saberes combinados
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.morado.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.morado.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Text('🌿', style: TextStyle(fontSize: 14)),
                          SizedBox(width: 6),
                          Text('Saberes combinados',
                              style: TextStyle(color: AppTheme.morado, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Ancestral + Moderno',
                        style: TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
              const Divider(height: 1),
              ..._saberes.map((s) => _SaberTile(saber: s)),
              const SizedBox(height: 8),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ── Modelos ───────────────────────────────────────────────────────────────────
enum _TipoAlerta { alerta, precaucion, lunar }

class _Alerta {
  final String letra;
  final Color color;
  final String titulo;
  final String subtitulo;
  final _TipoAlerta tipo;
  _Alerta({required this.letra, required this.color, required this.titulo, required this.subtitulo, required this.tipo});
}

class _SaberCombinado {
  final String emoji;
  final String titulo;
  final String detalle;
  _SaberCombinado({required this.emoji, required this.titulo, required this.detalle});
}

// ── Widgets ───────────────────────────────────────────────────────────────────
class _AlertaTile extends StatelessWidget {
  final _Alerta alerta;
  const _AlertaTile({required this.alerta});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
      ),
      child: Row(
        children: [
          // Barra lateral de color
          Container(
            width: 5,
            height: 70,
            decoration: BoxDecoration(
              color: alerta.color,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
            ),
          ),
          const SizedBox(width: 12),
          // Círculo con letra
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: alerta.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(alerta.letra,
                  style: TextStyle(color: alerta.color, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(alerta.titulo,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 3),
                  Text(alerta.subtitulo,
                      style: const TextStyle(color: Colors.grey, fontSize: 12, height: 1.3)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _SaberTile extends StatefulWidget {
  final _SaberCombinado saber;
  const _SaberTile({required this.saber});

  @override
  State<_SaberTile> createState() => _SaberTileState();
}

class _SaberTileState extends State<_SaberTile> {
  bool _expandido = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _expandido = !_expandido),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.morado.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: Text(widget.saber.emoji, style: const TextStyle(fontSize: 20))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.saber.titulo,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.morado)),
                      if (!_expandido)
                        const Text('Toca para ver el consejo completo',
                            style: TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                ),
                Icon(_expandido ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.grey),
              ],
            ),
          ),
        ),
        if (_expandido)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.morado.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border(left: BorderSide(color: AppTheme.morado.withValues(alpha: 0.4), width: 3)),
            ),
            child: Text(widget.saber.detalle,
                style: const TextStyle(fontSize: 13, height: 1.5, color: Colors.black87)),
          ),
        if (widget.saber != widget.saber) const Divider(height: 1, indent: 16),
      ],
    );
  }
}
