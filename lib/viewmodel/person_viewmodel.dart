import 'package:flutter/material.dart';
import '../model/person.dart';
import '../dao/person_dao.dart';

class PersonViewModel extends ChangeNotifier {
  final PersonDao personDao;

  PersonViewModel(this.personDao);

  Future<void> addPerson(String name, int age) async {
    final person = Person(name: name, age: age);
    await personDao.insertPerson(person);
    notifyListeners();
  }

  Stream<List<Person>> get persons => personDao.getAllPersons();
}
