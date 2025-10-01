import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tarefa.dart';
import 'app_drawer.dart';
import 'dart:convert';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TextEditingController _controller = TextEditingController();
  List<Tarefa> _tarefas = [];

  @override
  void initState() {
    super.initState();
    _carregarTarefas();
  }

  // FUNÇÃO PARA SALVAR AS TAREFAS
  Future<void> _salvarTarefas() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> listaJson = _tarefas
        .map((t) => jsonEncode(t.toJson()))
        .toList();
    await prefs.setStringList('tarefas', listaJson);
  }

  // FUNÇÃO PARA CARREGAR AS TAREFAS DO SHARED PREFERENCES
  Future<void> _carregarTarefas() async {
    final prefs = await SharedPreferences.getInstance();
    final listaJson = prefs.getStringList('tarefas') ?? [];
    setState(() {
      _tarefas = listaJson.map((t) => Tarefa.fromJson(jsonDecode(t))).toList();
      _ordenarTarefas();
    });
  }

  // FUNÇÃO PARA ORDENAR TAREFAS: CONCLUÍDAS NO FINAL
  void _ordenarTarefas() {
    _tarefas.sort((a, b) {
      if (a.concluida && !b.concluida) return 1;
      if (!a.concluida && b.concluida) return -1;
      return 0;
    });
  }

  // FUNÇÃO PARA ADICIONAR TAREFAS
  void _adicionarTarefa(String titulo) {
    if (titulo.isNotEmpty) {
      setState(() {
        _tarefas.add(Tarefa(titulo: titulo));
        _ordenarTarefas();
        _salvarTarefas();
        _controller.clear();
      });
    }
  }

  // FUNÇÃO PARA REMOVER TAREFAS
  void _removerTarefa(int index) {
    setState(() {
      _tarefas.removeAt(index);
      _salvarTarefas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TO-DO App"),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Digite uma tarefa...",
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _adicionarTarefa(_controller.text),
                  style: ElevatedButton.styleFrom(
                    elevation: 4,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  child: Text(
                    "Adicionar",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _tarefas.length,
                itemBuilder: (context, index) {
                  final tarefa = _tarefas[index];
                  return Dismissible(
                    key: ValueKey(tarefa.titulo),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) {
                      _removerTarefa(index);
                    },
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.endToStart) {
                        return await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Confirmar"),
                            content: const Text("Deseja remover esta tarefa?"),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text("Cancelar"),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text("Remover"),
                              ),
                            ],
                          ),
                        );
                      }
                      return true;
                    },
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 400),
                      opacity: tarefa.concluida
                          ? 0.5
                          : 1, // tarefas concluídas ficam mais transparentes

                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(16),
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: tarefa.concluida,
                            onChanged: (valor) {
                              setState(() {
                                tarefa.concluida = valor ?? false;
                                _ordenarTarefas();
                                _salvarTarefas();
                              });
                            },
                          ),
                          title: Text(
                            tarefa.titulo,
                            style: TextStyle(
                              fontSize: 18,
                              decoration: tarefa.concluida
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: tarefa.concluida
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removerTarefa(index),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _adicionarTarefa(_controller.text),
        backgroundColor: Colors.blue[900],
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }
}
