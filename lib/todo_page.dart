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

  Future<void> _salvarTarefas() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> listaJson = _tarefas
        .map((t) => jsonEncode(t.toJson()))
        .toList();
    await prefs.setStringList('tarefas', listaJson);
  }

  Future<void> _carregarTarefas() async {
    final prefs = await SharedPreferences.getInstance();
    final listaJson = prefs.getStringList('tarefas') ?? [];
    setState(() {
      _tarefas = listaJson.map((t) => Tarefa.fromJson(jsonDecode(t))).toList();
      _ordenarTarefas();
    });
  }

  void _ordenarTarefas() {
    _tarefas.sort((a, b) {
      if (a.concluida && !b.concluida) return 1;
      if (!a.concluida && b.concluida) return -1;
      return 0;
    });
  }

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

  void _removerTarefa(int index) {
    setState(() {
      _tarefas.removeAt(index);
      _salvarTarefas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Cabeçalho
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 20,
              ), // espaçamento ajustado
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(
                        Icons.menu,
                        size: 28,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ),
                  Text(
                    "DONE!",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
            ),

            // Campo de entrada e botão Adicionar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: "Digite uma tarefa...",
                        floatingLabelStyle: TextStyle(
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: Colors.teal, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: Colors.teal, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: Colors.teal, width: 2),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () => _adicionarTarefa(_controller.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      "Adicionar",
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Lista de tarefas
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 14),
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
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 400),
                      opacity: tarefa.concluida ? 0.5 : 1,
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.teal, width: 2),
                        ),
                        child: CheckboxListTile(
                          value: tarefa.concluida,
                          onChanged: (valor) {
                            setState(() {
                              tarefa.concluida = valor ?? false;
                              _ordenarTarefas();
                              _salvarTarefas();
                            });
                          },
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
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Botão Adicionar fixo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  onPressed: () => _adicionarTarefa(_controller.text),
                  backgroundColor: Colors.teal,
                  child: const Icon(Icons.add, size: 32, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
