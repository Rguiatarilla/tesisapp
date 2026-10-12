import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class PreciosScreen extends StatefulWidget {
  const PreciosScreen({super.key});

  @override
  State<PreciosScreen> createState() => _PreciosScreenState();
}

class _PreciosScreenState extends State<PreciosScreen> {
  late Timer _timer;
  DateTime _ultimaActualizacion = DateTime.now();

  // Precio base FNC (Federación Nacional de Cafeteros) en COP por carga de 125kg
  // Se simula variación diaria realista
  double _precioBase = 2850000;

  // Variedades de café con sus características de precio
  late List<_PrecioCafe> _precios;

  @override
  void initState() {
    super.initState();
    _calcularPrecios();
    // Actualiza cada 30 segundos (simula feed en tiempo real)
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        setState(() {
          // Variación aleatoria pequeña ±0.5%
          final variacion = (_precioBase * 0.005) * (DateTime.now().millisecond % 3 == 0 ? 1 : -1);
          _precioBase = (_precioBase + variacion).clamp(2500000, 3200000);
          _calcularPrecios();
          _ultimaActualizacion = DateTime.now();
        });
      }
    });
  }

  void _calcularPrecios() {
    _precios = [
      _PrecioCafe(
        variedad: 'Café Castillo',
        emoji: '☕',
        descripcion: 'Variedad resistente a la roya. La más cultivada en Nariño.',
        precioCarga: _precioBase,
        precioKg: _precioBase / 125,
        tendencia: _precioBase > 2850000 ? 1 : -1,
        calidad: 'Estándar FNC',
      ),
      _PrecioCafe(
        variedad: 'Café Colombia',
        emoji: '🫘',
        descripcion: 'Alta resistencia a enfermedades. Buena taza.',
        precioCarga: _precioBase * 1.02,
        precioKg: (_precioBase * 1.02) / 125,
        tendencia: 1,
        calidad: 'Estándar FNC',
      ),
      _PrecioCafe(
        variedad: 'Café Caturra',
        emoji: '🌿',
        descripcion: 'Variedad tradicional. Excelente calidad en taza.',
        precioCarga: _precioBase * 1.05,
        precioKg: (_precioBase * 1.05) / 125,
        tendencia: 1,
        calidad: 'Especial',
      ),
      _PrecioCafe(
        variedad: 'Café Típica',
        emoji: '🌱',
        descripcion: 'Variedad ancestral. Alta calidad, baja producción.',
        precioCarga: _precioBase * 1.12,
        precioKg: (_precioBase * 1.12) / 125,
        tendencia: 1,
        calidad: 'Especial',
      ),
      _PrecioCafe(
        variedad: 'Café Arábica Especial',
        emoji: '⭐',
        descripcion: 'Café de especialidad. Puntuación SCA > 80.',
        precioCarga: _precioBase * 1.35,
        precioKg: (_precioBase * 1.35) / 125,
        tendencia: 1,
        calidad: 'Especialidad',
      ),
    ];
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatPrecio(double precio) {
    if (precio >= 1000000) {
      return '\$${(precio / 1000000).toStringAsFixed(2)}M';
    }
    return '\$${precio.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.fondo,
      appBar: AppBar(
        backgroundColor: AppTheme.naranja,
        title: const Text('Precios del Café'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {
              _calcularPrecios();
              _ultimaActualizacion = DateTime.now();
            }),
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner precio FNC
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4E342E), Color(0xFF795548)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                const Text('Precio base FNC', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  '${_formatPrecio(_precioBase)} / carga',
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '≈ \$${(_precioBase / 125).toStringAsFixed(0)} por kg',
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.access_time, color: Colors.white54, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      'Actualizado: ${_ultimaActualizacion.hour}:${_ultimaActualizacion.minute.toString().padLeft(2, '0')}:${_ultimaActualizacion.second.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lista de variedades
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _precios.length,
              itemBuilder: (_, i) => _PrecioCard(precio: _precios[i], formatPrecio: _formatPrecio),
            ),
          ),

          // Nota informativa
          Container(
            padding: const EdgeInsets.all(12),
            color: AppTheme.tierraClaro,
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: AppTheme.tierra),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Precios de referencia basados en la FNC. Consulta tu cooperativa local para el precio exacto.',
                    style: TextStyle(fontSize: 11, color: AppTheme.tierra),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrecioCafe {
  final String variedad;
  final String emoji;
  final String descripcion;
  final double precioCarga;
  final double precioKg;
  final int tendencia; // 1 sube, -1 baja
  final String calidad;
  _PrecioCafe({
    required this.variedad, required this.emoji, required this.descripcion,
    required this.precioCarga, required this.precioKg,
    required this.tendencia, required this.calidad,
  });
}

class _PrecioCard extends StatelessWidget {
  final _PrecioCafe precio;
  final String Function(double) formatPrecio;
  const _PrecioCard({required this.precio, required this.formatPrecio});

  Color get _calidadColor {
    switch (precio.calidad) {
      case 'Especialidad': return AppTheme.morado;
      case 'Especial': return AppTheme.verde;
      default: return AppTheme.tierra;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Text(precio.emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(precio.variedad, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _calidadColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(precio.calidad, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _calidadColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(precio.descripcion, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(formatPrecio(precio.precioCarga),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.naranja)),
                        const Text('por carga 125kg', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('\$${precio.precioKg.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.tierra)),
                        const Text('por kg', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                    const Spacer(),
                    Icon(
                      precio.tendencia > 0 ? Icons.trending_up : Icons.trending_down,
                      color: precio.tendencia > 0 ? AppTheme.verde : AppTheme.rojo,
                      size: 22,
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
}
