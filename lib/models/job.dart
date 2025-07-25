import 'dart:ffi';

class Job {
  int? idJob; // '?' indica que pode ser nulo (para IDs auto-gerados)
  String titulo;
  String empresa;
  String descricao;
  String salario;

  Job({
    this.idJob,
    required this.titulo,
    required this.empresa,
    required this.descricao,
    required this.salario
  });

  // Método para converter um Map (do banco de dados) em um objeto Job
  factory Job.fromMap(Map<String, dynamic> json) => Job(
    idJob: json['idJob'],
    titulo: json['titulo'],
    empresa: json['empresa'],
    descricao: json['descricao'],
    salario: json['salario']
  );

  // Método para converter um objeto Job em um Map (para o banco de dados)
  Map<String, dynamic> toMap() {
    return {
      'idJob': idJob,
      'titulo': titulo,
      'empresa': empresa,
      'descricao': descricao,
      'salario': salario,
    };
  }
}