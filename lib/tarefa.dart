import 'dart:convert';

//CLASSE TAREFA
class Tarefa {
  String titulo;
  bool concluida;
  String categoria;
  String cor;

  Tarefa({
    required this.titulo,
    this.concluida = false,
    this.categoria = "Geral",
    this.cor = "#2196F3",
  });

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'concluida': concluida,
      'categoria': categoria,
      'cor': cor,
    };
  }

  factory Tarefa.fromMap(Map<String, dynamic> map) {
    return Tarefa(
      titulo: map['titulo'],
      concluida: map['concluida'],
      categoria: map['categoria'],
      cor: map['cor'],
    );
  }

  String toJson() => json.encode(toMap());
  factory Tarefa.fromJson(String source) => Tarefa.fromMap(json.decode(source));
}
