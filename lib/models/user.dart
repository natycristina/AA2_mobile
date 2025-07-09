class User {
  int? idUser;
  String nome;
  String email;
  String senha; // Em um app real, sempre armazene hashes de senhas!

  User({
    this.idUser,
    required this.nome,
    required this.email,
    required this.senha,
  });

  // Para converter Map (do SQLite) em objeto User
  factory User.fromMap(Map<String, dynamic> json) => User(
    idUser: json['idUser'],
    nome: json['nome'],
    email: json['email'],
    senha: json['senha'],
  );

  // Para converter objeto User em Map (para salvar no SQLite)
  Map<String, dynamic> toMap() {
    return {
      'idUser': idUser,
      'nome': nome,
      'email': email,
      'senha': senha,
    };
  }

  // <--- NOVO: Para converter JSON (do backend) em objeto User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      idUser: json['userId'] ?? json['idUser'], // Tente 'userId' ou 'idUser'
      nome: json['name'] ?? json['nome'] ?? '', // Tente 'name' ou 'nome'
      email: json['email'],
      senha: json['password'] ?? json['senha'], // Tente 'password' ou 'senha'
    );
  }

  // <--- NOVO: Para converter objeto User em JSON (para enviar ao backend)
  Map<String, dynamic> toJson() {
    return {
      'name': nome, // Ou 'nome' dependendo do backend
      'email': email,
      'password': senha, // Ou 'senha' dependendo do backend
    };
  }
}