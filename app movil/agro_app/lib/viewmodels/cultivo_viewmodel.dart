import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cultivo_model.dart';
import '../models/actividad_model.dart';
import '../models/novedad_model.dart';
import '../models/produccion_model.dart';
import '../services/cultivo_service.dart';

// --- Cultivos ---
class CultivoViewModel extends StateNotifier<List<CultivoModel>> {
  final CultivoService _service;
  final String usuarioNombre;

  CultivoViewModel(this._service, this.usuarioNombre) : super([]) {
    cargar();
  }

  Future<void> cargar() async {
    state = await _service.getCultivos(usuarioNombre);
  }

  Future<void> agregar(CultivoModel cultivo) async {
    await _service.agregarCultivo(cultivo);
    await cargar();
  }

  Future<void> eliminar(String id) async {
    await _service.eliminarCultivo(id);
    await cargar();
  }
}

// --- Actividades ---
class ActividadViewModel extends StateNotifier<List<ActividadModel>> {
  final CultivoService _service;
  final String cultivoId;

  ActividadViewModel(this._service, this.cultivoId) : super([]) {
    cargar();
  }

  Future<void> cargar() async {
    state = await _service.getActividades(cultivoId);
  }

  Future<void> agregar(ActividadModel actividad) async {
    await _service.agregarActividad(actividad);
    await cargar();
  }

  Future<void> editar(ActividadModel actividad) async {
    await _service.editarActividad(actividad);
    await cargar();
  }

  Future<void> eliminar(String id) async {
    await _service.eliminarActividad(id);
    await cargar();
  }
}

// --- Novedades ---
class NovedadViewModel extends StateNotifier<List<NovedadModel>> {
  final CultivoService _service;
  final String cultivoId;

  NovedadViewModel(this._service, this.cultivoId) : super([]) {
    cargar();
  }

  Future<void> cargar() async {
    state = await _service.getNovedades(cultivoId);
  }

  Future<void> agregar(NovedadModel novedad) async {
    await _service.agregarNovedad(novedad);
    await cargar();
  }

  Future<void> editar(NovedadModel novedad) async {
    await _service.editarNovedad(novedad);
    await cargar();
  }

  Future<void> eliminar(String id) async {
    await _service.eliminarNovedad(id);
    await cargar();
  }
}

// --- Producción ---
class ProduccionViewModel extends StateNotifier<List<ProduccionModel>> {
  final CultivoService _service;
  final String cultivoId;

  ProduccionViewModel(this._service, this.cultivoId) : super([]) {
    cargar();
  }

  Future<void> cargar() async {
    state = await _service.getProduccion(cultivoId);
  }

  Future<void> agregar(ProduccionModel prod) async {
    await _service.agregarProduccion(prod);
    await cargar();
  }

  Future<void> editar(ProduccionModel prod) async {
    await _service.editarProduccion(prod);
    await cargar();
  }

  Future<void> eliminar(String id) async {
    await _service.eliminarProduccion(id);
    await cargar();
  }
}

// --- Providers ---
final cultivoServiceProvider = Provider((_) => CultivoService());

final cultivoProvider = StateNotifierProvider.family<CultivoViewModel, List<CultivoModel>, String>(
  (ref, usuario) => CultivoViewModel(ref.read(cultivoServiceProvider), usuario),
);

final actividadProvider = StateNotifierProvider.family<ActividadViewModel, List<ActividadModel>, String>(
  (ref, cultivoId) => ActividadViewModel(ref.read(cultivoServiceProvider), cultivoId),
);

final novedadProvider = StateNotifierProvider.family<NovedadViewModel, List<NovedadModel>, String>(
  (ref, cultivoId) => NovedadViewModel(ref.read(cultivoServiceProvider), cultivoId),
);

final produccionProvider = StateNotifierProvider.family<ProduccionViewModel, List<ProduccionModel>, String>(
  (ref, cultivoId) => ProduccionViewModel(ref.read(cultivoServiceProvider), cultivoId),
);
