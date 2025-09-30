// Modelo de Dados para a Tarefa
class Task {
  final int? id;
  final String title;
  final String description;
  bool isCompleted;

  Task({
    this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
  });

  // Converte um objeto Task em um Map. Usado para inserir no banco de dados.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0, // SQLite não tem booleano, usa 0 ou 1
    };
  }

  // Converte um Map em um objeto Task. Usado para ler do banco de dados.
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isCompleted: map['isCompleted'] == 1,
    );
  }

  // Para facilitar a depuração
  @override
  String toString() {
    return 'Task{id: $id, title: $title, description: $description, isCompleted: $isCompleted}';
  }
}
