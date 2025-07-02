import 'package:floor/floor.dart';
import '../model/person.dart';

@dao
abstract class PersonDao {
  @Query('SELECT * FROM Person')
  Stream<List<Person>> getAllPersons();

  @insert
  Future<void> insertPerson(Person person);
}
