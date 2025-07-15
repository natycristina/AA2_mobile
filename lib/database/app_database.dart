// lib/database/app_database.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/job.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  static Database? _database;

  factory AppDatabase() {
    return _instance;
  }

  AppDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'jobtree_database.db');

    return await openDatabase(
      path,
      version: 5, // Aumente a versão para forçar _onUpgrade/recriação
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabela de Usuários
    await db.execute('''
      CREATE TABLE users (
        email TEXT UNIQUE PRIMARY KEY,
        nome TEXT,
        senha TEXT
      )
    ''');
    // Tabela de Vagas (exemplo)
    await db.execute('''
      CREATE TABLE jobs (
        idJob INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT,
        descricao TEXT,
        empresa TEXT,
        salario TEXT
      )
    ''');
    // Tabela de relação Usuário-Vaga (JobUser)
    await db.execute('''
      CREATE TABLE user_jobs (
        user_email TEXT,
        jobId INTEGER,
        PRIMARY KEY (user_email, jobId),
        FOREIGN KEY (user_email) REFERENCES users(email) ON DELETE CASCADE,
        FOREIGN KEY (jobId) REFERENCES jobs(idJob) ON DELETE CASCADE
      )
    ''');

    // Inserir usuário de teste e vagas iniciais
    final String testPasswordHash = 'password';
    await db.insert('users', {
      'nome': 'Usuário Teste',
      'email': 'test@example.com',
      'senha': testPasswordHash,
    });
    print('Usuário de teste inserido no SQLite.');

    // Inserir algumas vagas iniciais
    await db.insert('jobs', {
      'titulo': 'Desenvolvedor Flutter',
      'descricao': 'Vaga para desenvolvedor Flutter júnior.',
      'empresa': 'Tech Solutions',
      'salario': 'R\$ 3000',
    });
    await db.insert('jobs', {
      'titulo': 'Designer UI/UX',
      'descricao': 'Experiência com Figma e prototipagem.',
      'empresa': 'Creative Minds',
      'salario': 'R\$ 4500',
    });
    print('Vagas de teste inseridas no SQLite.');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // IMPORTANTE: Se a versão atual (que você está alterando) for 4, e você subiu para 5.
    // Isso vai dropar e recriar TUDO se a versão antiga for menor que 5.
    if (oldVersion < 5) {
      print('Database upgrade from version $oldVersion to $newVersion. Dropping and recreating tables...');
      await db.execute('DROP TABLE IF EXISTS user_jobs');
      await db.execute('DROP TABLE IF EXISTS users');
      await db.execute('DROP TABLE IF EXISTS jobs');
      await _onCreate(db, newVersion);
      print('Database upgraded and recreated for version 5.');
    }
    // Você pode adicionar outras lógicas de migração aqui para versões futuras
    // Ex: if (oldVersion < 6) { ... }
  }

  // Métodos CRUD para usuários
  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserByEmailAndSenha(String email, String passwordHash) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND senha = ?', // CORRIGIDO: nome da coluna é 'senha'
      whereArgs: [email, passwordHash],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertUser(User user) async {
    final db = await database;
    // user.toMap() já inclui o email para a PK
    return await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Métodos CRUD para vagas
  Future<List<Job>> getJobs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('jobs');
    return List.generate(maps.length, (i) {
      return Job.fromMap(maps[i]);
    });
  }

  Future<int> insertJob(Job job) async {
    final db = await database;
    return await db.insert('jobs', job.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Job?> getJobById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'jobs',
      where: 'idJob = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Job.fromMap(maps.first);
    }
    return null;
  }

  // Métodos para user_jobs
  Future<int> applyToJob(String userEmail, int jobId) async { // Parâmetro agora é String userEmail
    final db = await database;
    return await db.insert('user_jobs', {'user_email': userEmail, 'jobId': jobId}, conflictAlgorithm: ConflictAlgorithm.ignore); // CORRIGIDO: nome da coluna é 'user_email'
  }

  Future<List<Job>> getAppliedJobsForUser(String userEmail) async { // Parâmetro agora é String userEmail
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT j.idJob, j.titulo, j.descricao, j.empresa, j.salario
      FROM jobs j
      INNER JOIN user_jobs uj ON j.idJob = uj.jobId
      WHERE uj.user_email = ?
    ''', [userEmail]); // CORRIGIDO: usar user_email no WHERE clause

    return List.generate(maps.length, (i) {
      return Job.fromMap(maps[i]);
    });
  }

  // O método insertUserJob na sua nova tela ApplyToJobScreen chama este método.
  // Você não precisa dele se já tem applyToJob, mas se quiser mantê-lo, está aqui:
  Future<void> insertUserJob(String email, int jobId) async {
    final db = await database;
    await db.insert(
      'user_jobs',
      {
        'user_email': email, // CORRIGIDO: nome da coluna é 'user_email'
        'jobId': jobId,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }
}