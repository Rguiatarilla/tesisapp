import 'package:hive/hive.dart';

part 'novedad_model.g.dart';

@HiveType(typeId: 3)
class NovedadModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String cultivoId;

  @HiveField(2)
  final DateTime fecha;

  @HiveField(3)
  final String descripcion;

  @HiveField(4)
  final String tipo; // 'Plaga', 'Enfermedad', 'Clima', 'Crecimiento', 'Otro'

  @HiveField(5)
  final String estado; // 'Normal', 'Atención', 'Crítico'

  NovedadModel({
    required this.id,
    required this.cultivoId,
    required this.fecha,
    required this.descripcion,
    required this.tipo,
    required this.estado,
  });
}
