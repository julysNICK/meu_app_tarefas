import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../models/task_model.dart';

// Tela Principal da Lista de Tarefas
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // Carrega as tarefas do banco de dados.
  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });
    final tasks = await DatabaseHelper.instance.getTasks();
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  // Adiciona ou atualiza uma tarefa.
  Future<void> _upsertTask(String title, String description, {Task? task}) async {
    if (task == null) {
      // Adicionar nova tarefa
      final newTask = Task(title: title, description: description);
      await DatabaseHelper.instance.insertTask(newTask);
    } else {
      // Atualizar tarefa existente
      final updatedTask = Task(
        id: task.id,
        title: title,
        description: description,
        isCompleted: task.isCompleted,
      );
      await DatabaseHelper.instance.updateTask(updatedTask);
    }
    _loadTasks(); // Recarrega a lista para atualizar a UI.
  }

  // Marca uma tarefa como concluída/não concluída.
  Future<void> _toggleTaskCompletion(Task task) async {
    final updatedTask = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      isCompleted: !task.isCompleted,
    );
    await DatabaseHelper.instance.updateTask(updatedTask);
    _loadTasks(); // Recarrega a lista.
  }

  // Deleta uma tarefa.
  Future<void> _deleteTask(int id) async {
    await DatabaseHelper.instance.deleteTask(id);
    _loadTasks(); // Recarrega a lista.
  }

  // Exibe um AlertDialog para adicionar ou editar uma tarefa.
  void _showAddTaskDialog({Task? task}) {
    final titleController = TextEditingController(text: task?.title ?? '');
    final descriptionController = TextEditingController(text: task?.description ?? '');

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(task == null ? 'Nova Tarefa' : 'Editar Tarefa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  _upsertTask(
                    titleController.text,
                    descriptionController.text,
                    task: task,
                  );
                  Navigator.pop(dialogContext);
                }
              },
              child: Text(task == null ? 'Adicionar' : 'Salvar'),
            ),
          ],
        );
      },
    );
  }

  // Simula a sincronização.
  void _syncTasks() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Sincronizando ${_tasks.length} tarefas..."),
        duration: const Duration(seconds: 2),
      ),
    );
    // Em um app real, aqui você faria chamadas para um backend.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Tarefas Offline'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _syncTasks,
            tooltip: 'Sincronizar Tarefas',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? const Center(child: Text('Nenhuma tarefa encontrada!'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: CheckboxListTile(
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            color: task.isCompleted ? Colors.grey : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          task.description,
                          style: TextStyle(
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            color: task.isCompleted ? Colors.grey[600] : Colors.grey[800],
                          ),
                        ),
                        value: task.isCompleted,
                        onChanged: (bool? newValue) {
                          _toggleTaskCompletion(task);
                        },
                        secondary: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showAddTaskDialog(task: task),
                              tooltip: 'Editar Tarefa',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteTask(task.id!),
                              tooltip: 'Deletar Tarefa',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(),
        tooltip: 'Adicionar Nova Tarefa',
        child: const Icon(Icons.add),
      ),
    );
  }
}
