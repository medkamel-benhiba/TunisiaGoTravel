// artisanat_provider.dart
import 'package:flutter/material.dart';
import '../models/artisanat.dart';
import '../services/api_service.dart';

class ArtisanatProvider with ChangeNotifier {
  final ApiService apiService;

  ArtisanatProvider({required this.apiService});

  List<Artisanat> _artisanats = [];
  Artisanat? _selectedArtisanat;
  bool _isLoading = false;
  String? _error;

  List<Artisanat> get artisanats => _artisanats;
  Artisanat? get selectedArtisanat => _selectedArtisanat;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchArtisanats() async {
    _setLoading(true);
    try {
      _artisanats = await apiService.getArtisanat();
      _error = null;
    } catch (e) {
      _artisanats = [];
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchArtisanatBySlug(String slug) async {
    _setLoading(true);
    _selectedArtisanat = null;
    _error = null;

    try {
      // First, try to find in existing artisanats list
      final existingArtisanat = _artisanats.firstWhere(
            (artisanat) => artisanat.slug == slug,
        orElse: () => Artisanat(
          id: '',
          name: '',
          nameEn: '',
          nameKo: '',
          nameAr: '',
          nameZh: '',
          nameRu: '',
          nameJa: '',
          description: '',
          descriptionEn: '',
          descriptionKo: '',
          descriptionAr: '',
          descriptionZh: '',
          descriptionRu: '',
          descriptionJa: '',
          slug: '',
          videoLink: '',
          cover: '',
          vignette: '',
          images: [],
          seo: Seo.fromJson({}),
        ),
      );

      if (existingArtisanat.id.isNotEmpty) {
        _selectedArtisanat = existingArtisanat;
      } else {
        // If not found in list, fetch from API
        // You'll need to add this method to your ApiService
        _selectedArtisanat = await apiService.getArtisanatBySlug(slug);
      }
    } catch (e) {
      _error = e.toString();
      _selectedArtisanat = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshArtisanats() async => fetchArtisanats();

  // Clear selected artisanat (useful when navigating away)
  void clearSelectedArtisanat() {
    _selectedArtisanat = null;
    notifyListeners();
  }

  // Reset error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}