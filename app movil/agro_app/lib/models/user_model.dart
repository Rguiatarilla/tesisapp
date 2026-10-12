import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String nombre;

  @HiveField(1)
  final String nombreFinca;

  @HiveField(2)
  final String password;

  @HiveField(3)
  final String celular;

  UserModel({
    required this.nombre,
    required this.nombreFinca,
    required this.password,
    this.celular = '',
  });
}
