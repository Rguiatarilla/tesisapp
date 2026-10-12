import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/user_model.dart';
import 'models/cultivo_model.dart';
import 'models/actividad_model.dart';
import 'models/novedad_model.dart';
import 'models/produccion_model.dart';
import 'theme/app_theme.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/register_screen.dart';
import 'views/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(CultivoModelAdapter());
  Hive.registerAdapter(ActividadModelAdapter());
  Hive.registerAdapter(NovedadModelAdapter());
  Hive.registerAdapter(ProduccionModelAdapter());
  runApp(const ProviderScope(child: AgroApp()));
}

class AgroApp extends ConsumerWidget {
  const AgroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'AgroApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  bool _checking = true;
  bool _hasAnyUser = false;
  bool _showLogin = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    await ref.read(authProvider.notifier).checkSession();
    final hasUser = await ref.read(authServiceProvider).hasAnyUser();
    if (mounted) {
      setState(() {
        _checking = false;
        _hasAnyUser = hasUser;
        _showLogin = hasUser;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F5DC),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50))),
      );
    }

    final user = ref.watch(authProvider).user;

    if (user != null) return const HomeScreen();

    if (_showLogin || _hasAnyUser) {
      return LoginScreen(onGoToRegister: () => setState(() => _showLogin = false));
    }
    return RegisterScreen(onGoToLogin: () => setState(() => _showLogin = true));
  }
}
