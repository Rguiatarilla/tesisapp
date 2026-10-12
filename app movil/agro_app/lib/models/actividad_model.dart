import 'package:hive/hive.dart';

part 'actividad_model.g.dart';

@HiveType(typeId: 2)
class ActividadModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String cultivoId;

  @HiveField(2)
  final String tipo; // siembra, riego, fertilización, cosecha, etc.

  @HiveField(3)
  final DateTime fecha;

  @HiveField(4)
  final String notas;

  ActividadModel({
    required this.id,
    required this.cultivoId,
    required this.tipo,
    required this.fecha,
    required this.notas,
  });
}
