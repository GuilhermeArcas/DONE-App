import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'login_page.dart';
import 'update_name_page.dart';
import 'change_password_page.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    final user = authService.value.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            accountName: Text(user?.displayName ?? "Sem nome"),
            accountEmail: Text(user?.email ?? "Sem e-mail"),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.blue),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.blue),
            title: const Text("Atualizar Nome"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UpdateNamePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.email, color: Colors.blue),
            title: const Text("Redefinir Senha por E-mail"),
            onTap: () async {
              final email = user?.email;
              if (email != null) {
                await authService.value.resetPassword(email: email);

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Link enviado para $email")),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.password, color: Colors.blue),
            title: const Text("Alterar senha"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.blue),
            title: const Text("Sair"),
            onTap: () async {
              await authService.value.signOut();

              if (!mounted) return;

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
