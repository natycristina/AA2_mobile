

import 'package:flutter_projects/models/user.dart';
import 'package:flutter_projects/repositories/user_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_projects/database/app_database.dart';
import 'package:flutter_projects/services/user_api_service.dart';
import 'user_repository_test.mocks.dart';

@GenerateMocks([AppDatabase, UserApiService, SharedPreferencesOptions])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  late MockAppDatabase mockAppDatabase;
  late MockUserApiService mockUserApiService;
  late UserRepository userRepository;

  setUp(() async {
    mockAppDatabase = MockAppDatabase();
    mockUserApiService = MockUserApiService();

    userRepository = UserRepository(
      database: mockAppDatabase,
      apiService: mockUserApiService,
    );
  });

  test('loginUser deve retornar o usuário do backend e salvar localmente', () async {
    const email = 'user@example.com';
    const password = '1234';
    final user = User(nome: 'Usuário Teste', email: email, senha: password);

    when(mockUserApiService.loginUser(email, password)).thenAnswer((_) async => user);
    when(mockAppDatabase.insertUser(user)).thenAnswer((_) async => 1);
    when(mockAppDatabase.getUserByEmailAndSenha(email, password)).thenAnswer((_) async => null);

    final result = await userRepository.loginUser(email, password);

    expect(result, isNotNull);
    expect(result!.email, equals(email));
    verify(mockUserApiService.loginUser(email, password)).called(1);
    verify(mockAppDatabase.insertUser(user)).called(1);
  });

  test('loginUser deve fazer fallback para login local se o backend falhar', () async {
    const email = 'user@example.com';
    const password = '1234';
    final user = User(nome: 'Usuário Local', email: email, senha: password);

    when(mockUserApiService.loginUser(email, password))
        .thenThrow(Exception('sem conexão'));
    when(mockAppDatabase.getUserByEmailAndSenha(email, password))
        .thenAnswer((_) async => user);

    final result = await userRepository.loginUser(email, password);

    expect(result, isNotNull);
    expect(result!.email, equals(email));
    verify(mockUserApiService.loginUser(email, password)).called(1);
    verify(mockAppDatabase.getUserByEmailAndSenha(email, password)).called(1);
  });

  test('registerUser deve retornar true se registro no backend for bem-sucedido', () async {
    const nome = 'Usuário Teste';
    const email = 'teste@example.com';
    const password = '1234';

    final user = User(nome: nome, email: email, senha: password);

    // Simula a chamada do backend que retorna o usuário criado
    when(mockUserApiService.registerUser(nome, email, password))
        .thenAnswer((_) async => user);

    // Simula a inserção no banco local que retorna 1 (id, por exemplo)
    when(mockAppDatabase.insertUser(user))
        .thenAnswer((_) async => 1);

    final result = await userRepository.registerUser(nome, email, password);

    expect(result, isTrue);
    verify(mockUserApiService.registerUser(nome, email, password)).called(1);
    verify(mockAppDatabase.insertUser(user)).called(1);
  });

  test('registerUser deve retornar false se registro no backend retornar null', () async {
    const nome = 'Usuário Teste';
    const email = 'teste@example.com';
    const password = '1234';

    // Simula falha no backend (retorna null)
    when(mockUserApiService.registerUser(nome, email, password))
        .thenAnswer((_) async => null);

    final result = await userRepository.registerUser(nome, email, password);

    expect(result, isFalse);
    verify(mockUserApiService.registerUser(nome, email, password)).called(1);
    verifyNever(mockAppDatabase.insertUser(any));
  });

  test('registerUser deve retornar false se o backend lançar exceção', () async {
    const nome = 'Usuário Teste';
    const email = 'teste@example.com';
    const password = '1234';

    // Simula exceção no backend
    when(mockUserApiService.registerUser(nome, email, password))
        .thenThrow(Exception('Erro de rede'));

    final result = await userRepository.registerUser(nome, email, password);

    expect(result, isFalse);
    verify(mockUserApiService.registerUser(nome, email, password)).called(1);
    verifyNever(mockAppDatabase.insertUser(any));
  });
}