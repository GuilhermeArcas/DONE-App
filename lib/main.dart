import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'todo_page.dart';
import 'firebase_options.dart'; // arquivo gerado pelo FlutterFire CLI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();
  final keepConnected = prefs.getBool("keepConnected") ?? false;

  User? user = FirebaseAuth.instance.currentUser;

  runApp(TodoApp(isLoggedIn: user != null && keepConnected));
}

class TodoApp extends StatelessWidget {
  final bool isLoggedIn;
  const TodoApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "App de Tarefas",
      theme: ThemeData(
        //COR PRINCIPAL DO APP
        primarySwatch: Colors.blue,
        //COR DO FUNDO PADRÃO
        scaffoldBackgroundColor: Colors.white,

        // AppBar ESTILIZADA
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        //CAMPOS DE TEXTO (INPUT)
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),

      routes: {
        "/login": (context) => const LoginPage(),
        "/register": (context) => const RegisterPage(),
        "/todo": (context) => const TodoPage(),
      },
      // 🔑 Redireciona automaticamente baseado no estado do usuário
      home: StreamBuilder<User?>(
        stream: authService.value.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return FutureBuilder<bool>(
              future: SharedPreferences.getInstance().then(
                (prefs) => prefs.getBool("keepConnected") ?? false,
              ),
              builder: (context, snapshotPrefs) {
                if (!snapshotPrefs.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return snapshotPrefs.data!
                    ? const TodoPage()
                    : const LoginPage();
              },
            );
          }
          return const LoginPage();
        },
      ),
    );
  }
}
