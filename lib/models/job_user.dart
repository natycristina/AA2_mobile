class JobUser {
  int? id; // ID próprio da candidatura (opcional, se for apenas uma relação N:N)
  int userId;
  int jobId;
  String status; // Ex: "Aplicado", "Entrevistado", "Rejeitado"

  JobUser({
    this.id,
    required this.userId,
    required this.jobId,
    this.status = 'Aplicado', // Valor padrão
  });

  factory JobUser.fromMap(Map<String, dynamic> json) => JobUser(
    id: json['id'],
    userId: json['userId'],
    jobId: json['jobId'],
    status: json['status'],
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'jobId': jobId,
      'status': status,
    };
  }
}