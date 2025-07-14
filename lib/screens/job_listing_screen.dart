// lib/screens/job_listing_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/job.dart';
import '../viewmodels/job_listing_viewmodel.dart';

class JobListingScreen extends StatelessWidget {
  const JobListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context)!;
    final viewModel = Provider.of<JobListingViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          texts.jobTree, // "JobTree" traduzido
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF9FC9EB), // Cor VoeBlueLight
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.black87),
            onPressed: () {
              // TODO: Implementar navegação para o perfil do usuário
              // Navigator.pushNamed(context, '/userProfile');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(texts.profileTitle)),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Gradiente de fundo - similar ao Box de Kotlin/Compose
          Container(
            height: MediaQuery.of(context).size.height * 0.25, // Ajuste para 25% da altura
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF9FC9EB), Colors.white], // VoeBlueLight para White
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Text(
                  texts.findNextOpportunity, // "Encontre sua próxima oportunidade"
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600], // VoeTextGrey
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // SearchBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: TextField(
                  onChanged: (query) {
                    viewModel.onSearchQueryChanged(query);
                  },
                  decoration: InputDecoration(
                    hintText: texts.searchPositions, // "Search positions"
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(21.0), // RoundedCornerShape(21.dp)
                      borderSide: BorderSide.none, // Remover borda padrão se desejar apenas a cor de fundo
                    ),
                    filled: true,
                    fillColor: Colors.white, // Cor de fundo da search bar
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16), // Espaçamento entre SearchBar e JobList
              // JobList
              Expanded(
                child: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : viewModel.filteredJobs.isEmpty
                    ? Center(child: Text(texts.noJobsFound))
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  itemCount: viewModel.filteredJobs.length,
                  itemBuilder: (context, index) {
                    final job = viewModel.filteredJobs[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: JobCard(
                        job: job,
                        onTap: () { ClickOnJob(context, job); },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onTap;

  const JobCard({
    super.key,
    required this.job,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 8,
      color: Colors.white,
      child: InkWell( // Use InkWell para o efeito de clique
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job.titulo,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                job.empresa,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                job.descricao,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                job.salario,
                style: Theme.of(context).textTheme.bodyMedium
              )
            ],
          ),
        ),
      ),
    );
  }
}

void ClickOnJob(BuildContext context, Job selectedJob) {
  Navigator.pushReplacementNamed(context, '/jobApplication', arguments: {'selectedJob': selectedJob});
}

void OnBack(BuildContext context) {
  Navigator.pushReplacementNamed(context, '/home');
}