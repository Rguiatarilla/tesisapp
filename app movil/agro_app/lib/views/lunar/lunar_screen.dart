import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

// ── Ilustración de luna dibujada con Canvas ───────────────────────────────────
class LunaIlustracion extends StatelessWidget {
  final double porcentajeCiclo; // 0.0 a 1.0
  final double size;
  const LunaIlustracion({super.key, required this.porcentajeCiclo, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _LunaPainter(porcentajeCiclo: porcentajeCiclo),
    );
  }
}

class _LunaPainter extends CustomPainter {
  final double porcentajeCiclo;
  _LunaPainter({required this.porcentajeCiclo});

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final center = Offset(r, r);

    // Fondo oscuro de la luna (parte en sombra)
    final darkPaint = Paint()..color = const Color(0xFF2C3E50);
    canvas.drawCircle(center, r, darkPaint);

    // Parte iluminada (dorada/amarilla)
    final lightPaint = Paint()..color = const Color(0xFFE8C84A);

    // Calcular la fase: 0=nueva, 0.25=creciente, 0.5=llena, 0.75=menguante
    final fase = porcentajeCiclo;

    if (fase < 0.03 || fase > 0.97) {
      // Luna nueva: toda oscura, solo un borde sutil
      final borderPaint = Paint()
        ..color = const Color(0xFF4A5568)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(center, r - 0.75, borderPaint);
    } else if (fase < 0.5) {
      // Creciente: iluminado a la derecha
      final t = fase / 0.5; // 0 a 1
      final path = Path();
      // Semicírculo derecho iluminado
      path.addArc(Rect.fromCircle(center: center, radius: r), -math.pi / 2, math.pi);
      // Elipse que define el terminador
      final rx = r * (1 - 2 * t).abs();
      if (t < 0.5) {
        // Creciente: elipse oscura a la izquierda
        canvas.drawCircle(center, r, lightPaint);
        final darkEllipse = Paint()..color = const Color(0xFF2C3E50);
        final ellipseRect = Rect.fromCenter(center: center, width: rx * 2, height: r * 2);
        canvas.drawOval(ellipseRect, darkEllipse);
        // Tapar mitad izquierda
        final leftPaint = Paint()..color = const Color(0xFF2C3E50);
        canvas.drawRect(Rect.fromLTWH(0, 0, r, size.height), leftPaint);
      } else {
        // Gibosa creciente
        canvas.drawCircle(center, r, lightPaint);
        final darkEllipse = Paint()..color = const Color(0xFF2C3E50);
        final ellipseRect = Rect.fromCenter(center: center, width: rx * 2, height: r * 2);
        canvas.drawOval(ellipseRect, darkEllipse);
        canvas.drawRect(Rect.fromLTWH(0, 0, r, size.height), Paint()..color = const Color(0xFF2C3E50));
        // Restaurar lado derecho
        canvas.drawCircle(center, r, lightPaint);
        canvas.save();
        canvas.clipRect(Rect.fromLTWH(r, 0, r, size.height));
        canvas.drawCircle(center, r, lightPaint);
        canvas.restore();
        canvas.save();
        canvas.clipRect(Rect.fromLTWH(0, 0, r, size.height));
        canvas.drawOval(ellipseRect, darkEllipse);
        canvas.restore();
      }
    } else if (fase < 0.53) {
      // Luna llena
      canvas.drawCircle(center, r, lightPaint);
      // Cráteres sutiles
      final craterPaint = Paint()..color = const Color(0xFFD4A820).withValues(alpha: 0.4);
      canvas.drawCircle(Offset(r * 0.7, r * 0.6), r * 0.12, craterPaint);
      canvas.drawCircle(Offset(r * 1.2, r * 0.8), r * 0.08, craterPaint);
      canvas.drawCircle(Offset(r * 0.9, r * 1.3), r * 0.1, craterPaint);
    } else {
      // Menguante: iluminado a la izquierda
      final t = (fase - 0.5) / 0.5; // 0 a 1
      canvas.drawCircle(center, r, lightPaint);
      final rx = r * (1 - 2 * t).abs();
      final darkEllipse = Paint()..color = const Color(0xFF2C3E50);
      if (t < 0.5) {
        // Gibosa menguante
        canvas.save();
        canvas.clipRect(Rect.fromLTWH(r, 0, r, size.height));
        final ellipseRect = Rect.fromCenter(center: center, width: rx * 2, height: r * 2);
        canvas.drawOval(ellipseRect, darkEllipse);
        canvas.restore();
      } else {
        // Menguante
        canvas.save();
        canvas.clipRect(Rect.fromLTWH(r, 0, r, size.height));
        canvas.drawCircle(center, r, darkEllipse);
        canvas.restore();
        final ellipseRect = Rect.fromCenter(center: center, width: rx * 2, height: r * 2);
        canvas.save();
        canvas.clipRect(Rect.fromLTWH(0, 0, r, size.height));
        canvas.drawOval(ellipseRect, darkEllipse);
        canvas.restore();
      }
    }

    // Clip circular para bordes limpios
    final clipPath = Path()..addOval(Rect.fromCircle(center: center, radius: r));
    canvas.clipPath(clipPath);
  }

  @override
  bool shouldRepaint(_LunaPainter old) => old.porcentajeCiclo != porcentajeCiclo;
}

// ── Widget pequeño de luna para el calendario ─────────────────────────────────
class LunaMini extends StatelessWidget {
  final double porcentajeCiclo;
  final double size;
  const LunaMini({super.key, required this.porcentajeCiclo, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _LunaMiniPainter(porcentajeCiclo: porcentajeCiclo),
    );
  }
}

class _LunaMiniPainter extends CustomPainter {
  final double porcentajeCiclo;
  _LunaMiniPainter({required this.porcentajeCiclo});

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final center = Offset(r, r);
    final fase = porcentajeCiclo;

    final darkPaint = Paint()..color = const Color(0xFF2C3E50);
    final lightPaint = Paint()..color = const Color(0xFFE8C84A);

    canvas.drawCircle(center, r, darkPaint);

    if (fase >= 0.03 && fase <= 0.97) {
      if (fase >= 0.47 && fase <= 0.53) {
        canvas.drawCircle(center, r, lightPaint);
      } else if (fase < 0.5) {
        final t = fase / 0.5;
        final rx = r * (1 - 2 * t).abs();
        if (t >= 0.5) {
          canvas.drawCircle(center, r, lightPaint);
          canvas.save();
          canvas.clipRect(Rect.fromLTWH(0, 0, r, size.height));
          canvas.drawOval(Rect.fromCenter(center: center, width: rx * 2, height: r * 2), darkPaint);
          canvas.restore();
        } else {
          canvas.save();
          canvas.clipRect(Rect.fromLTWH(r, 0, r, size.height));
          canvas.drawCircle(center, r, lightPaint);
          canvas.restore();
          canvas.save();
          canvas.clipRect(Rect.fromLTWH(r, 0, r, size.height));
          canvas.drawOval(Rect.fromCenter(center: center, width: rx * 2, height: r * 2), darkPaint);
          canvas.restore();
        }
      } else {
        final t = (fase - 0.5) / 0.5;
        final rx = r * (1 - 2 * t).abs();
        canvas.drawCircle(center, r, lightPaint);
        if (t < 0.5) {
          canvas.save();
          canvas.clipRect(Rect.fromLTWH(r, 0, r, size.height));
          canvas.drawOval(Rect.fromCenter(center: center, width: rx * 2, height: r * 2), darkPaint);
          canvas.restore();
        } else {
          canvas.save();
          canvas.clipRect(Rect.fromLTWH(r, 0, r, size.height));
          canvas.drawCircle(center, r, darkPaint);
          canvas.restore();
          canvas.save();
          canvas.clipRect(Rect.fromLTWH(0, 0, r, size.height));
          canvas.drawOval(Rect.fromCenter(center: center, width: rx * 2, height: r * 2), darkPaint);
          canvas.restore();
        }
      }
    }
  }

  @override
  bool shouldRepaint(_LunaMiniPainter old) => old.porcentajeCiclo != porcentajeCiclo;
}

class LunarScreen extends StatefulWidget {
  const LunarScreen({super.key});

  @override
  State<LunarScreen> createState() => _LunarScreenState();
}

class _LunarScreenState extends State<LunarScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Timer _timer;
  DateTime _ahora = DateTime.now();
  int _mesSeleccionado = DateTime.now().month - 1; // 0-indexed

  static const _meses = ['Enero','Febrero','Marzo','Abril','Mayo','Junio',
    'Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() => _ahora = DateTime.now());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _timer.cancel();
    super.dispose();
  }

  static _FaseInfo _calcularFase(DateTime fecha) {
    final ref = DateTime(2000, 1, 6);
    final diff = fecha.difference(ref).inDays;
    const ciclo = 29.53058867;
    final fase = (diff % ciclo + ciclo) % ciclo;
    final pct = fase / ciclo;

    if (fase < 1.85) return _FaseInfo('Luna Nueva', '🌑', fase, pct, const Color(0xFF1A237E));
    if (fase < 7.38) return _FaseInfo('Luna Creciente', '🌒', fase, pct, const Color(0xFF4527A0));
    if (fase < 9.22) return _FaseInfo('Cuarto Creciente', '🌓', fase, pct, AppTheme.azul);
    if (fase < 14.77) return _FaseInfo('Gibosa Creciente', '🌔', fase, pct, const Color(0xFF00695C));
    if (fase < 16.61) return _FaseInfo('Luna Llena', '🌕', fase, pct, const Color(0xFFF57F17));
    if (fase < 22.15) return _FaseInfo('Gibosa Menguante', '🌖', fase, pct, AppTheme.naranja);
    if (fase < 23.99) return _FaseInfo('Cuarto Menguante', '🌗', fase, pct, AppTheme.verde);
    return _FaseInfo('Luna Menguante', '🌘', fase, pct, const Color(0xFF37474F));
  }

  static String _descripcionCafe(_FaseInfo f) {
    switch (f.nombre) {
      case 'Luna Nueva':
        return '🌱 Preparación del suelo\n\nLa tierra está en su punto más receptivo. '
            'Aplica abonos orgánicos como pulpa de café y ceniza. '
            'Los nutrientes se absorben con mayor eficiencia.\n\n'
            '✅ Ideal para: abonar, preparar semilleros, planificar labores del mes.';
      case 'Luna Creciente':
        return '🌱 Siembra y trasplante\n\nLa savia del café sube con fuerza hacia las ramas. '
            'Las plantas sembradas en esta fase echan raíz más rápido.\n\n'
            '✅ Ideal para: sembrar colinos, trasplantar, injertos, fertilización foliar.';
      case 'Cuarto Creciente':
        return '🌿 Crecimiento activo\n\nEl café está en pleno desarrollo vegetativo. '
            'Excelente momento para estimular el crecimiento.\n\n'
            '✅ Ideal para: fertilización, control de plagas, podas de formación en colinos.';
      case 'Gibosa Creciente':
        return '🌿 Vigor máximo\n\nLos árboles de café están en su mayor actividad. '
            'Las heridas cicatrizan bien y los rebrotes son vigorosos.\n\n'
            '✅ Ideal para: podas de renovación, deschuponada, manejo de sombra.';
      case 'Luna Llena':
        return '☕ Cosecha de calidad\n\nEl grano de café alcanza su mayor peso y contenido de azúcares. '
            'Los caficultores de Yacuanquer siempre cosechaban en luna llena.\n\n'
            '✅ Ideal para: cosechar café maduro, beneficio húmedo, secado al sol.\n'
            '⚠️ Evita: siembra y trasplante.';
      case 'Gibosa Menguante':
        return '☕ Cosecha y beneficio\n\nLa savia empieza a bajar. Los granos están en su punto óptimo '
            'de madurez y sabor en taza.\n\n'
            '✅ Ideal para: cosechar, fermentar y secar el café, almacenamiento del grano.';
      case 'Cuarto Menguante':
        return '🌿 Control y limpieza\n\nLa savia baja hacia las raíces. '
            'Las malezas arrancadas tardan más en rebrotar.\n\n'
            '✅ Ideal para: deshierbe, control de malezas, aplicación de fungicidas y herbicidas.';
      default:
        return '🌙 Descanso del cafetal\n\nPeriodo de transición. La planta descansa y acumula energía.\n\n'
            '✅ Ideal para: revisar el estado general del cafetal, limpiar herramientas, planificar.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final faseHoy = _calcularFase(_ahora);

    return Scaffold(
      backgroundColor: AppTheme.fondo,
      appBar: AppBar(
        backgroundColor: AppTheme.morado,
        title: const Text('Fase Lunar'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [Tab(text: 'Hoy'), Tab(text: 'Calendario anual')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TabHoy(fase: faseHoy, ahora: _ahora, meses: _meses, descripcion: _descripcionCafe(faseHoy)),
          _TabCalendarioAnual(
            ahora: _ahora,
            meses: _meses,
            mesSeleccionado: _mesSeleccionado,
            onMesCambiado: (m) => setState(() => _mesSeleccionado = m),
            calcularFase: _calcularFase,
            descripcionCafe: _descripcionCafe,
          ),
        ],
      ),
    );
  }
}

// ─── TAB 1: HOY ───────────────────────────────────────────────────────────────
class _TabHoy extends StatelessWidget {
  final _FaseInfo fase;
  final DateTime ahora;
  final List<String> meses;
  final String descripcion;
  const _TabHoy({required this.fase, required this.ahora, required this.meses, required this.descripcion});

  @override
  Widget build(BuildContext context) {
    final diasRestantes = (29.53 - fase.diaEnCiclo).round();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [fase.color, fase.color.withValues(alpha: 0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: fase.color.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Column(
              children: [
                LunaIlustracion(porcentajeCiclo: fase.porcentajeCiclo, size: 110),                const SizedBox(height: 10),
                Text(fase.nombre, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 6),
                Text('${ahora.day} de ${meses[ahora.month - 1]} · ${ahora.hour}:${ahora.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('🌑', style: TextStyle(color: Colors.white60, fontSize: 11)),
                  Text('Día ${fase.diaEnCiclo.toStringAsFixed(1)} / 29.5', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                  const Text('🌑', style: TextStyle(color: Colors.white60, fontSize: 11)),
                ]),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(value: fase.porcentajeCiclo, backgroundColor: Colors.white24, color: Colors.white, minHeight: 8),
                ),
                const SizedBox(height: 6),
                Text('Próxima luna nueva en $diasRestantes días', style: const TextStyle(color: Colors.white60, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border(left: BorderSide(color: fase.color, width: 4)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Para tu cafetal hoy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: fase.color)),
                const SizedBox(height: 8),
                Text(descripcion, style: const TextStyle(fontSize: 13, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── TAB 2: CALENDARIO ANUAL ──────────────────────────────────────────────────
class _TabCalendarioAnual extends StatelessWidget {
  final DateTime ahora;
  final List<String> meses;
  final int mesSeleccionado;
  final ValueChanged<int> onMesCambiado;
  final _FaseInfo Function(DateTime) calcularFase;
  final String Function(_FaseInfo) descripcionCafe;

  const _TabCalendarioAnual({
    required this.ahora, required this.meses, required this.mesSeleccionado,
    required this.onMesCambiado, required this.calcularFase, required this.descripcionCafe,
  });

  @override
  Widget build(BuildContext context) {
    final anio = ahora.year;
    final diasEnMes = DateUtils.getDaysInMonth(anio, mesSeleccionado + 1);
    final primerDia = DateTime(anio, mesSeleccionado + 1, 1);
    final offsetDias = primerDia.weekday % 7; // 0=Dom

    return Column(
      children: [
        // Selector de mes horizontal
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            itemCount: 12,
            itemBuilder: (_, i) {
              final seleccionado = i == mesSeleccionado;
              return GestureDetector(
                onTap: () => onMesCambiado(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: seleccionado ? AppTheme.morado : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4)],
                  ),
                  child: Text(
                    meses[i].substring(0, 3),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: seleccionado ? Colors.white : Colors.black54,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Cabecera días de la semana
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: ['Dom','Lun','Mar','Mié','Jue','Vie','Sáb']
                .map((d) => Expanded(child: Center(child: Text(d, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)))))
                .toList(),
          ),
        ),

        // Grid del calendario
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: offsetDias + diasEnMes,
              itemBuilder: (_, index) {
                if (index < offsetDias) return const SizedBox();
                final dia = index - offsetDias + 1;
                final fecha = DateTime(anio, mesSeleccionado + 1, dia);
                final fase = calcularFase(fecha);
                final esHoy = fecha.year == ahora.year && fecha.month == ahora.month && fecha.day == ahora.day;

                return GestureDetector(
                  onTap: () => _mostrarDetalle(context, fecha, fase),
                  child: Container(
                    decoration: BoxDecoration(
                      color: esHoy ? fase.color : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: esHoy ? fase.color : Colors.grey.shade200),
                      boxShadow: esHoy ? [BoxShadow(color: fase.color.withValues(alpha: 0.3), blurRadius: 6)] : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LunaMini(porcentajeCiclo: fase.porcentajeCiclo, size: 22),
                        Text(
                          '$dia',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: esHoy ? FontWeight.bold : FontWeight.normal,
                            color: esHoy ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _mostrarDetalle(BuildContext context, DateTime fecha, _FaseInfo fase) {
    final mesesNombres = ['Enero','Febrero','Marzo','Abril','Mayo','Junio',
      'Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        maxChildSize: 0.85,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Row(
                children: [
                  LunaIlustracion(porcentajeCiclo: fase.porcentajeCiclo, size: 64),                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(fase.nombre, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: fase.color)),
                        Text('${fecha.day} de ${mesesNombres[fecha.month - 1]} de ${fecha.year}',
                            style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: fase.color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border(left: BorderSide(color: fase.color, width: 4)),
                ),
                child: Text(descripcionCafe(fase), style: const TextStyle(fontSize: 14, height: 1.6)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaseInfo {
  final String nombre;
  final String emoji;
  final double diaEnCiclo;
  final double porcentajeCiclo;
  final Color color;
  _FaseInfo(this.nombre, this.emoji, this.diaEnCiclo, this.porcentajeCiclo, this.color);
}
