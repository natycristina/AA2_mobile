import 'package:flutter_projects/models/job.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_projects/repositories/job_repository.dart';
import 'package:flutter_projects/database/app_database.dart';
import 'job_repository_test.mocks.dart';

@GenerateMocks([AppDatabase])
void main() {
  late MockAppDatabase mockDatabase;
  late JobRepository repository;

  setUp(() {
    mockDatabase = MockAppDatabase();
    repository = JobRepository(database: mockDatabase);
  });

  test('getJobs deve retornar uma lista de vagas', () async {
    final jobsList = [
      Job(idJob: 1, titulo: 'Desenvolvedor Flutter', descricao: 'Vaga 1', empresa: "Empresa X", salario: "1200"),
      Job(idJob: 2, titulo: 'Designer UX', descricao: 'Vaga 2', empresa: "Empresa Y", salario: "2700"),
    ];

    when(mockDatabase.getJobs()).thenAnswer((_) async => jobsList);

    final result = await repository.getJobs();

    expect(result, isA<List<Job>>());
    expect(result.length, equals(2));
    expect(result[0].titulo, contains('Flutter'));
    verify(mockDatabase.getJobs()).called(1);
  });

  test('getJobById deve retornar uma vaga específica pelo ID', () async {
    final job = Job(idJob: 1, titulo: 'Desenvolvedor Flutter', descricao: 'Vaga 1', empresa: "Empresa Z", salario: "3500");

    when(mockDatabase.getJobById(1)).thenAnswer((_) async => job);

    final result = await repository.getJobById(1);

    expect(result, isNotNull);
    expect(result!.idJob, equals(1));
    expect(result.titulo, contains('Flutter'));
    verify(mockDatabase.getJobById(1)).called(1);
  });

  test('insertJob deve retornar o id da vaga inserida', () async {
    final newJob = Job(idJob: 0, titulo: 'Product Manager', descricao: 'Nova vaga', empresa: 'Empresa W', salario: "90");

    when(mockDatabase.insertJob(newJob)).thenAnswer((_) async => 10);

    final result = await repository.insertJob(newJob);

    expect(result, equals(10));
    verify(mockDatabase.insertJob(newJob)).called(1);
  });
}