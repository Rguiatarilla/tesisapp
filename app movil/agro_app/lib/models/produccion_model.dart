import 'package:hive/hive.dart';

part 'produccion_model.g.dart';

@HiveType(typeId: 4)
class ProduccionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String cultivoId;

  @HiveField(2)
  final DateTime fechaCosecha;

  @HiveField(3)
  final double cantidad;

  @HiveField(4)
  final String unidad; // 'kg', 'cargas', 'bultos', 'arrobas'

  @HiveField(5)
  final String notas;

  ProduccionModel({
    required this.id,
    required this.cultivoId,
    required this.fechaCosecha,
    required this.cantidad,
    required this.unidad,
    required this.notas,
  });
}
