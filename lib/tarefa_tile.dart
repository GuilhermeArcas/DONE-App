import 'package:flutter/material.dart';
import 'tarefa.dart';

class TarefaTile extends StatelessWidget {
  final Tarefa tarefa;
  final Function(bool?) onChanged;
  final VoidCallback onDismissed;

  const TarefaTile({
    super.key,
    required this.tarefa,
    required this.onChanged,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(tarefa.titulo + tarefa.hashCode.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) => onDismissed(),
      child: ListTile(
        leading: Checkbox(value: tarefa.concluida, onChanged: onChanged),
        title: Text(
          tarefa.titulo,
          style: TextStyle(
            decoration: tarefa.concluida
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: Color(
              int.parse(tarefa.cor.substring(1, 7), radix: 16) + 0xFF000000,
            ),
          ),
        ),
        subtitle: Text(tarefa.categoria),
      ),
    );
  }
}
