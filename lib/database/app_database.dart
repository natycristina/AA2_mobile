import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/job.dart'; // Importe o modelo Job aqui
// import 'package:bcrypt/bcrypt.dart'; // Se for usar bcrypt em Flutter

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
      version: 4, // Incrementar a versão quando houver mudanças no schema
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
    // Tabela de relação Usuário-Vaga (JobUser) se necessário
    await db.execute('''
      CREATE TABLE user_jobs (
        user_email TEXT,
        jobId INTEGER,
        PRIMARY KEY (user_email, jobId),
        FOREIGN KEY (user_email) REFERENCES users(email) ON DELETE CASCADE,
        FOREIGN KEY (jobId) REFERENCES jobs(idJob) ON DELETE CASCADE
      )
    ''');

    // Inserir usuário de teste e vagas iniciais (semelhante ao seu AppDatabaseCallback)
    // CUIDADO: Se você estiver usando o backend para login, este usuário local pode ser apenas
    // para testes offline ou para a fase inicial de desenvolvimento.
    // final hashedPassword = BCrypt.hashpw('password', BCrypt.gensalt()); // Se estiver usando bcrypt
    final String testPasswordHash = 'password'; // Use um hash real se bcrypt estiver habilitado
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
    // Lógica para migração de banco de dados se a versão mudar
    // Por exemplo, se newVersion > oldVersion, adicione colunas ou tabelas
    if (oldVersion < 4) {
      // Exemplo: Adicionar uma nova coluna na versão 2
      // await db.execute('ALTER TABLE users ADD COLUMN nome TEXT PRIMARY KEY');
      // await db.execute('ALTER TABLE users DROP COLUMN');
    }
  }

  // Métodos CRUD para usuários (equivalente ao UserDao)
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
      where: 'email = ? AND password = ?', // A senha aqui seria o hash armazenado
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
    return await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Métodos CRUD para vagas (equivalente ao JobDao)
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

  // Métodos para JobUser (se necessário)
  Future<int> applyToJob(String userEmail, int jobId) async {
    final db = await database;
    return await db.insert('user_jobs', {'userEmail': userEmail, 'jobId': jobId});
  }

  // --- NOVOS MÉTODOS ADICIONADOS PARA RESOLVER ERROS ---

  // Método para obter uma vaga por ID (para JobRepository)
  Future<Job?> getJobById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'jobs',
      where: 'idJob = ?', // Supondo que a coluna do ID da vaga é 'idJob'
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Job.fromMap(maps.first);
    }
    return null;
  }

  // Método para obter vagas aplicadas por um usuário (para UserRepository)
  Future<List<Job>> getAppliedJobsForUser(int userId) async {
    final db = await database;
    // Esta query recupera os detalhes das vagas que um usuário aplicou
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT j.idJob, j.title, j.description, j.company, j.salary
      FROM jobs j
      INNER JOIN user_jobs uj ON j.idJob = uj.jobId
      WHERE uj.userId = ?
    ''', [userId]);

    return List.generate(maps.length, (i) {
      return Job.fromMap(maps[i]);
    });
  }
// --- FIM DOS NOVOS MÉTODOS ---
}