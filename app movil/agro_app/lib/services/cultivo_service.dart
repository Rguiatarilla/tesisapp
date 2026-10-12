import 'package:hive_flutter/hive_flutter.dart';
import '../models/cultivo_model.dart';
import '../models/actividad_model.dart';
import '../models/novedad_model.dart';
import '../models/produccion_model.dart';

class CultivoService {
  static const _cultivosBox = 'cultivos';
  static const _actividadesBox = 'actividades';
  static const _novedadesBox = 'novedades';
  static const _produccionBox = 'produccion';

  Future<void> agregarCultivo(CultivoModel cultivo) async {
    final box = await Hive.openBox<CultivoModel>(_cultivosBox);
    await box.put(cultivo.id, cultivo);
  }

  Future<List<CultivoModel>> getCultivos(String usuarioNombre) async {
    final box = await Hive.openBox<CultivoModel>(_cultivosBox);
    return box.values.where((c) => c.usuarioNombre == usuarioNombre).toList()
      ..sort((a, b) => b.fechaSiembra.compareTo(a.fechaSiembra));
  }

  Future<void> eliminarCultivo(String id) async {
    final box = await Hive.openBox<CultivoModel>(_cultivosBox);
    await box.delete(id);
    // Eliminar actividades asociadas
    final actBox = await Hive.openBox<ActividadModel>(_actividadesBox);
    final actKeys = actBox.values
        .where((a) => a.cultivoId == id)
        .map((a) => a.id)
        .toList();
    for (final k in actKeys) {
      await actBox.delete(k);
    }
    // Eliminar novedades asociadas
    final novBox = await Hive.openBox<NovedadModel>(_novedadesBox);
    final novKeys = novBox.values
        .where((n) => n.cultivoId == id)
        .map((n) => n.id)
        .toList();
    for (final k in novKeys) {
      await novBox.delete(k);
    }
    // Eliminar producción asociada
    final prodBox = await Hive.openBox<ProduccionModel>(_produccionBox);
    final prodKeys = prodBox.values
        .where((p) => p.cultivoId == id)
        .map((p) => p.id)
        .toList();
    for (final k in prodKeys) {
      await prodBox.delete(k);
    }
  }

  Future<void> agregarActividad(ActividadModel actividad) async {
    final box = await Hive.openBox<ActividadModel>(_actividadesBox);
    await box.put(actividad.id, actividad);
  }

  Future<void> editarActividad(ActividadModel actividad) async {
    final box = await Hive.openBox<ActividadModel>(_actividadesBox);
    await box.put(actividad.id, actividad);
  }

  Future<void> eliminarActividad(String id) async {
    final box = await Hive.openBox<ActividadModel>(_actividadesBox);
    await box.delete(id);
  }

  Future<List<ActividadModel>> getActividades(String cultivoId) async {
    final box = await Hive.openBox<ActividadModel>(_actividadesBox);
    return box.values.where((a) => a.cultivoId == cultivoId).toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
  }

  Future<List<ActividadModel>> getActividadesPorFecha(
      String cultivoId, DateTime fecha) async {
    final box = await Hive.openBox<ActividadModel>(_actividadesBox);
    return box.values
        .where((a) =>
            a.cultivoId == cultivoId &&
            a.fecha.year == fecha.year &&
            a.fecha.month == fecha.month &&
            a.fecha.day == fecha.day)
        .toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
  }

  Future<Set<String>> getDiasConActividades(
      String cultivoId, int year, int month) async {
    final box = await Hive.openBox<ActividadModel>(_actividadesBox);
    return box.values
        .where((a) =>
            a.cultivoId == cultivoId &&
            a.fecha.year == year &&
            a.fecha.month == month)
        .map((a) => '${a.fecha.day}')
        .toSet();
  }

  // ── Novedades ──────────────────────────────────────────────────────────────

  Future<void> agregarNovedad(NovedadModel novedad) async {
    final box = await Hive.openBox<NovedadModel>(_novedadesBox);
    await box.put(novedad.id, novedad);
  }

  Future<void> editarNovedad(NovedadModel novedad) async {
    final box = await Hive.openBox<NovedadModel>(_novedadesBox);
    await box.put(novedad.id, novedad);
  }

  Future<void> eliminarNovedad(String id) async {
    final box = await Hive.openBox<NovedadModel>(_novedadesBox);
    await box.delete(id);
  }

  Future<List<NovedadModel>> getNovedades(String cultivoId) async {
    final box = await Hive.openBox<NovedadModel>(_novedadesBox);
    return box.values
        .where((n) => n.cultivoId == cultivoId)
        .toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
  }

  // ── Producción ─────────────────────────────────────────────────────────────

  Future<void> agregarProduccion(ProduccionModel prod) async {
    final box = await Hive.openBox<ProduccionModel>(_produccionBox);
    await box.put(prod.id, prod);
  }

  Future<void> editarProduccion(ProduccionModel prod) async {
    final box = await Hive.openBox<ProduccionModel>(_produccionBox);
    await box.put(prod.id, prod);
  }

  Future<void> eliminarProduccion(String id) async {
    final box = await Hive.openBox<ProduccionModel>(_produccionBox);
    await box.delete(id);
  }

  Future<List<ProduccionModel>> getProduccion(String cultivoId) async {
    final box = await Hive.openBox<ProduccionModel>(_produccionBox);
    return box.values
        .where((p) => p.cultivoId == cultivoId)
        .toList()
      ..sort((a, b) => b.fechaCosecha.compareTo(a.fechaCosecha));
  }
}
