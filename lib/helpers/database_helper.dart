import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/task_model.dart';

// Classe de Ajuda para o Banco de Dados
class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  DatabaseHelper._privateConstructor();

  // Getter para o banco de dados. Se não existir, inicializa.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  // Inicializa o banco de dados SQLite.
  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    // Usando o alias 'p' para a função join do pacote path.
    final path = p.join(dbPath, 'tasks.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          '''
          CREATE TABLE tasks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            isCompleted INTEGER
          )
          ''',
        );
      },
    );
  }

  // Insere uma nova tarefa no banco de dados.
  Future<int> insertTask(Task task) async {
    final db = await instance.database;
    return await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Busca todas as tarefas do banco de dados.
  Future<List<Task>> getTasks() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');

    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  // Atualiza uma tarefa existente no banco de dados.
  Future<int> updateTask(Task task) async {
    final db = await instance.database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // Deleta uma tarefa do banco de dados.
  Future<int> deleteTask(int id) async {
    final db = await instance.database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
