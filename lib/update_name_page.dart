import 'package:flutter/material.dart';
import 'auth_service.dart';

class UpdateNamePage extends StatefulWidget {
  const UpdateNamePage({super.key});

  @override
  State<UpdateNamePage> createState() => _UpdateNamePageState();
}

class _UpdateNamePageState extends State<UpdateNamePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Preenche o campo com o nome atual, se existir
    _nameController.text = authService.value.currentUser?.displayName ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateName() async {
    if (!_formKey.currentState!.validate()) return;

    final newName = _nameController.text.trim();
    setState(() => _isLoading);

    try {
      // chama o método do AuthService que atualiza o displayName
      await authService.value.updateUsername(username: newName);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Nome atualizado com sucesso!")));

      //Fecha a página e volta
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao atualizar nome: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Atualizar nome'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Novo nome',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.done,
                validator: (v) {
                  final s = v?.trim() ?? '';
                  if (s.isEmpty) return 'Digite um nome';
                  if (s.length < 2) return 'Nome muito curto';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateName,
                  child: _isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Salvar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
