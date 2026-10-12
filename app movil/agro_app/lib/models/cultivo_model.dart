import 'package:hive/hive.dart';

part 'cultivo_model.g.dart';

@HiveType(typeId: 1)
class CultivoModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String tipo;

  @HiveField(2)
  final DateTime fechaSiembra;

  @HiveField(3)
  final String ubicacion;

  @HiveField(4)
  final double areHectareas;

  @HiveField(5)
  final String usuarioNombre;

  @HiveField(6)
  final double altitud; // metros sobre el nivel del mar

  @HiveField(7)
  final String etapaCultivo; // 'Semillero', 'Almácigo', 'Siembra', 'Crecimiento', 'Floración', 'Fructificación', 'Cosecha'

  CultivoModel({
    required this.id,
    required this.tipo,
    required this.fechaSiembra,
    required this.ubicacion,
    required this.areHectareas,
    required this.usuarioNombre,
    this.altitud = 0,
    this.etapaCultivo = 'Crecimiento',
  });
}
