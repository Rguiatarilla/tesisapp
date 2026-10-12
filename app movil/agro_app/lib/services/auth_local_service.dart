import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';

class AuthLocalService {
  static const _boxName = 'users';
  static const _sessionKey = 'session';

  // Registrar usuario
  Future<bool> register(
    String nombre,
    String nombreFinca,
    String password, {
    String celular = '',
  }) async {
    final box = await Hive.openBox<UserModel>(_boxName);
    final existe = box.values.any((u) => u.nombre == nombre);
    if (existe) return false;

    final user = UserModel(
      nombre: nombre,
      nombreFinca: nombreFinca,
      password: password,
      celular: celular,
    );
    await box.put(nombre, user);
    return true;
  }

  // Iniciar sesión
  Future<UserModel?> login(String nombre, String password) async {
    final box = await Hive.openBox<UserModel>(_boxName);
    final user = box.get(nombre);
    if (user != null && user.password == password) {
      final sessionBox = await Hive.openBox(_sessionKey);
      await sessionBox.put('currentUser', nombre);
      return user;
    }
    return null;
  }

  // Obtener usuario de sesión activa
  Future<UserModel?> getSession() async {
    final sessionBox = await Hive.openBox(_sessionKey);
    final nombreActual = sessionBox.get('currentUser');
    if (nombreActual == null) return null;
    final box = await Hive.openBox<UserModel>(_boxName);
    return box.get(nombreActual);
  }

  // Cerrar sesión
  Future<void> logout() async {
    final sessionBox = await Hive.openBox(_sessionKey);
    await sessionBox.delete('currentUser');
  }

  // Verificar si ya existe algún usuario registrado
  Future<bool> hasAnyUser() async {
    final box = await Hive.openBox<UserModel>(_boxName);
    return box.isNotEmpty;
  }

  // Actualizar perfil
  Future<void> actualizarPerfil({
    required String nombreActual,
    required String nuevoNombre,
    required String nuevaFinca,
    String? celular,
  }) async {
    final box = await Hive.openBox<UserModel>(_boxName);
    final user = box.get(nombreActual);
    if (user == null) return;

    final actualizado = UserModel(
      nombre: nuevoNombre,
      nombreFinca: nuevaFinca,
      password: user.password,
      celular: celular ?? user.celular,
    );

    if (nombreActual != nuevoNombre) {
      await box.delete(nombreActual);
    }
    await box.put(nuevoNombre, actualizado);

    final sessionBox = await Hive.openBox(_sessionKey);
    await sessionBox.put('currentUser', nuevoNombre);
  }

  // Recuperar contraseña: verifica nombre + celular y actualiza la contraseña
  Future<bool> recuperarContrasena({
    required String nombre,
    required String celular,
    required String nuevaPassword,
  }) async {
    final box = await Hive.openBox<UserModel>(_boxName);
    final user = box.get(nombre);
    if (user == null) return false;

    // Normalizar celular para comparar solo dígitos
    final celularRegistrado = user.celular.replaceAll(RegExp(r'\D'), '');
    final celularIngresado = celular.replaceAll(RegExp(r'\D'), '');
    if (celularRegistrado != celularIngresado) return false;

    final actualizado = UserModel(
      nombre: user.nombre,
      nombreFinca: user.nombreFinca,
      password: nuevaPassword,
      celular: user.celular,
    );
    await box.put(nombre, actualizado);
    return true;
  }
}
