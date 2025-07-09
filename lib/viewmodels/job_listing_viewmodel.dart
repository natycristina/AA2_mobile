// lib/viewmodels/job_listing_viewmodel.dart
import 'package:flutter/material.dart';
import '../models/job.dart';
import '../repositories/job_repository.dart';

class JobListingViewModel extends ChangeNotifier {
  final JobRepository _jobRepository;
  List<Job> _allJobs = [];
  List<Job> _filteredJobs = [];
  String _searchQuery = '';
  bool _isLoading = false;

  JobListingViewModel({JobRepository? jobRepository})
      : _jobRepository = jobRepository ?? JobRepository() {
    _fetchJobs();
  }

  List<Job> get filteredJobs => _filteredJobs;
  bool get isLoading => _isLoading;

  Future<void> _fetchJobs() async {
    _isLoading = true;
    notifyListeners();
    try {
      // Aqui você chamaria a API real se tivesse uma rota para listar vagas
      // Por enquanto, usamos a simulação do repositório
      _allJobs = await _jobRepository.getJobs();
      _applyFilter();
    } catch (e) {
      print('Erro ao carregar vagas: $e');
      // Tratar o erro, talvez mostrar uma mensagem para o usuário
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void onSearchQueryChanged(String query) {
    _searchQuery = query;
    _applyFilter();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredJobs = List.from(_allJobs);
    } else {
      _filteredJobs = _allJobs.where((job) {
        final queryLower = _searchQuery.toLowerCase();
        return job.titulo.toLowerCase().contains(queryLower) ||
            job.empresa.toLowerCase().contains(queryLower) ||
            job.descricao.toLowerCase().contains(queryLower);
      }).toList();
    }
    notifyListeners();
  }
}