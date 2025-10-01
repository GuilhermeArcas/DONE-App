import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final current = _currentController.text.trim();
    final fresh = _newController.text.trim();
    final confirm = _confirmController.text.trim();

    if (fresh != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('A nova senha e a confirmação não coincidem')),
      );
      return;
    }

    if (fresh.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('A nova senha deve ter ao menos 6 caracteres')),
      );
      return;
    }

    final email = authService.value.currentUser?.email;
    if (email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuário não encontrado. Faça login novamente')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // esse método reautentica e atualiza a senha internamente
      await authService.value.resetPasswordFromCurrentPassword(
        currentPassword: current,
        newPassword: fresh,
        email: email,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Senha alterada com sucesso!')));

      // Limpa campos e volta
      _currentController.clear();
      _newController.clear();
      _confirmController.clear();
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      String message = 'Erro ao alterar a senha';
      if (e.code == 'wrong-password') {
        message = 'Senha atual incorreta';
      } else if (e.code == 'weak-password') {
        message = 'Senha fraca (mínimo 6 caracteres)';
      } else if (e.code == 'requires-recent-login') {
        message = 'Você precisa entrar novamente antes de alterar a senha';
      } else if (e.message != null) {
        message = e.message!;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alterar senha'), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _currentController,
                decoration: const InputDecoration(
                  labelText: 'Senha atual',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Digite a senha atual' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _newController,
                decoration: const InputDecoration(
                  labelText: 'Nova senha',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (v) => (v == null || v.length < 6)
                    ? 'Senha muito curta. No mínimo 6 caracteres'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmController,
                decoration: const InputDecoration(
                  labelText: 'Confirmar nova senha',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Confirme a nova senha' : null,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _changePassword,
                  child: _isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Alterar Senha'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
