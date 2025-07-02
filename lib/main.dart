import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database/app_database.dart';
import 'viewmodel/person_viewmodel.dart';
import 'model/person.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await $FloorAppDatabase.databaseBuilder('app.db').build();
  runApp(MyApp(database));
}

class MyApp extends StatelessWidget {
  final AppDatabase database;

  const MyApp(this.database, {super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PersonViewModel(database.personDao),
      child: MaterialApp(
        home: PersonPage(),
      ),
    );
  }
}

class PersonPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  PersonPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<PersonViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Pessoas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text;
                final age = int.tryParse(ageController.text) ?? 0;
                if (name.isNotEmpty && age > 0) {
                  viewModel.addPerson(name, age);
                  nameController.clear();
                  ageController.clear();
                }
              },
              child: const Text('Add'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<Person>>(
                stream: viewModel.persons,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const CircularProgressIndicator();
                  final people = snapshot.data!;
                  return ListView.builder(
                    itemCount: people.length,
                    itemBuilder: (_, index) {
                      final p = people[index];
                      return ListTile(
                        title: Text('${p.name} (${p.age})'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
