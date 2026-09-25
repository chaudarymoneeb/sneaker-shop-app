import 'package:flutter/material.dart';
import '../model/cart_item_model.dart';
import '../model/shoe_model.dart';
import '../model/services/supabase_service.dart';

class CartProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<CartItemModel> _items = [];
  String? _uid;

  List<CartItemModel> get items => _items;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get shipping => _items.isEmpty ? 0 : 10.0;
  double get total => subtotal + shipping;

  /// Call this once a user logs in (and with the live catalog) to start syncing their cart.
  void bindUser(String uid, List<ShoeModel> catalog) {
    _uid = uid;
    _supabaseService.streamCart(uid, catalog).listen((cartItems) {
      _items = cartItems;
      notifyListeners();
    });
  }

  void clearLocal() {
    _items = [];
    _uid = null;
    notifyListeners();
  }

  Future<void> addToCart(
    ShoeModel shoe,
    String size,
    String color, {
    int quantity = 1,
  }) async {
    if (_uid == null) return;
    final item = CartItemModel(
      shoe: shoe,
      selectedSize: size,
      selectedColor: color,
      quantity: quantity,
    );
    await _supabaseService.addToCart(_uid!, item);
  }

  Future<void> updateQuantity(CartItemModel item, int quantity) async {
    if (_uid == null) return;
    await _supabaseService.updateCartQuantity(
      _uid!,
      item.shoe.id,
      item.selectedSize,
      item.selectedColor,
      quantity,
    );
  }

  Future<void> removeItem(CartItemModel item) async {
    if (_uid == null) return;
    await _supabaseService.removeFromCart(
      _uid!,
      item.shoe.id,
      item.selectedSize,
      item.selectedColor,
    );
  }

  Future<String?> checkout(String address) async {
    if (_uid == null || _items.isEmpty) return null;
    return _supabaseService.placeOrder(_uid!, _items, total, address);
  }
}
