import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_local_service.dart';

// Estado de autenticación
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({UserModel? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthLocalService _service;

  AuthViewModel(this._service) : super(const AuthState());

  Future<void> checkSession() async {
    final user = await _service.getSession();
    state = AuthState(user: user);
  }

  Future<bool> register(
    String nombre,
    String nombreFinca,
    String password, {
    String celular = '',
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final ok = await _service.register(nombre, nombreFinca, password, celular: celular);
    if (!ok) {
      state = state.copyWith(isLoading: false, error: 'El usuario ya existe');
      return false;
    }
    // Auto-login tras registro
    final user = await _service.login(nombre, password);
    state = AuthState(user: user);
    return true;
  }

  Future<bool> login(String nombre, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    final user = await _service.login(nombre, password);
    if (user == null) {
      state = state.copyWith(isLoading: false, error: 'Nombre o contraseña incorrectos');
      return false;
    }
    state = AuthState(user: user);
    return true;
  }

  Future<void> logout() async {
    await _service.logout();
    state = const AuthState();
  }

  Future<bool> recuperarContrasena({
    required String nombre,
    required String celular,
    required String nuevaPassword,
  }) async {
    return _service.recuperarContrasena(
      nombre: nombre,
      celular: celular,
      nuevaPassword: nuevaPassword,
    );
  }
}

// Providers
final authServiceProvider = Provider((_) => AuthLocalService());

final authProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(ref.read(authServiceProvider));
});
