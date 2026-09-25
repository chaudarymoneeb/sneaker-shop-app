import 'package:flutter/material.dart';
import '../model/shoe_model.dart';
import '../model/services/supabase_service.dart';

class ShoeProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<ShoeModel> _allShoes = [];
  List<ShoeModel> _featuredShoes = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = true;

  final List<String> categories = [
    'All',
    'Running',
    'Basketball',
    'Lifestyle',
    'Training',
  ];

  List<ShoeModel> get allShoes => _allShoes;
  List<ShoeModel> get featuredShoes => _featuredShoes;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;

  List<ShoeModel> get filteredShoes {
    var list = _selectedCategory == 'All'
        ? _allShoes
        : _allShoes.where((s) => s.category == _selectedCategory).toList();
    if (_searchQuery.isNotEmpty) {
      list = list
          .where(
            (s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
    return list;
  }

  ShoeProvider() {
    _allShoes = _localShoes;
    _featuredShoes = _localShoes.take(4).toList();
    _isLoading = false;
    _listenToShoes();
    _listenToFeatured();
  }

  List<ShoeModel> get _localShoes => [
    ...List.generate(10, (index) {
      final assetName = index == 0 ? '0.jpg' : '0$index.jpg';
      return ShoeModel(
        id: 'local-featured-$index',
        name: 'Air Max Feature ${index + 1}',
        price: 99 + (index * 12.5),
        category: categories[(index % (categories.length - 1)) + 1],
        images: ['assets/images/$assetName'],
        imageUrl: 'assets/images/$assetName',
        sizes: _defaultSizes,
      );
    }),
    ...List.generate(17, (index) {
      final assetName = '${index + 1}.jpg';
      return ShoeModel(
        id: 'local-catalog-$index',
        name: 'Street Runner ${index + 1}',
        price: 79 + (index * 13.5),
        category: categories[(index % (categories.length - 1)) + 1],
        images: ['assets/images/$assetName'],
        imageUrl: 'assets/images/$assetName',
        sizes: _defaultSizes,
      );
    }),
  ];

  static const List<String> _defaultSizes = [
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
  ];

  void _listenToShoes() {
    _supabaseService.streamShoes().listen(
      (shoes) {
        if (shoes.isNotEmpty) _allShoes = shoes;
        _isLoading = false;
        notifyListeners();
      },
      onError: (_, _) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void _listenToFeatured() {
    _supabaseService.streamFeaturedShoes().listen((shoes) {
      if (shoes.isNotEmpty) _featuredShoes = shoes;
      notifyListeners();
    }, onError: (_, _) => notifyListeners());
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  ShoeModel? getShoeById(String id) {
    try {
      return _allShoes.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
