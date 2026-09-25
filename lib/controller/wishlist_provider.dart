import 'package:flutter/material.dart';
import '../model/services/supabase_service.dart';
import '../model/shoe_model.dart';

class WishlistProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<String> _wishlistIds = [];
  String? _uid;

  List<String> get wishlistIds => _wishlistIds;

  void bindUser(String uid) {
    _uid = uid;
    _supabaseService.streamWishlistIds(uid).listen((ids) {
      _wishlistIds = ids;
      notifyListeners();
    });
  }

  void clearLocal() {
    _wishlistIds = [];
    _uid = null;
    notifyListeners();
  }

  bool isWishlisted(String shoeId) => _wishlistIds.contains(shoeId);

  Future<void> toggle(ShoeModel shoe) async {
    if (_uid == null) return;
    await _supabaseService.toggleWishlist(_uid!, shoe);
  }
}
