import 'package:supabase_flutter/supabase_flutter.dart';

import '../cart_item_model.dart';
import '../shoe_model.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Stream<List<ShoeModel>> streamShoes() => _client
      .from('shoes')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false)
      .map((rows) => rows.map(ShoeModel.fromMap).toList());

  Stream<List<ShoeModel>> streamFeaturedShoes() => _client
      .from('shoes')
      .stream(primaryKey: ['id'])
      .eq('is_featured', true)
      .order('created_at', ascending: false)
      .map((rows) => rows.map(ShoeModel.fromMap).toList());

  Stream<List<CartItemModel>> streamCart(String uid, List<ShoeModel> catalog) =>
      _client
          .from('cart_items')
          .stream(primaryKey: ['id'])
          .eq('user_id', uid)
          .map(
            (rows) => rows.map((row) {
              final shoe = catalog.firstWhere(
                (item) => item.id == row['shoe_id'],
                orElse: () => ShoeModel.fromMap(
                  (row['shoe'] as Map?)?.cast<String, dynamic>() ?? row,
                ),
              );
              return CartItemModel.fromMap(row, shoe);
            }).toList(),
          );

  Stream<List<String>> streamWishlistIds(String uid) => _client
      .from('wishlist')
      .stream(primaryKey: ['user_id', 'shoe_id'])
      .eq('user_id', uid)
      .map((rows) => rows.map((row) => row['shoe_id'] as String).toList());

  Future<void> addToCart(String uid, CartItemModel item) => _client
      .from('cart_items')
      .upsert(item.toMap(uid), onConflict: 'user_id,shoe_id,size,color');

  Future<void> updateCartQuantity(
    String uid,
    String shoeId,
    String size,
    String color,
    int quantity,
  ) => quantity <= 0
      ? removeFromCart(uid, shoeId, size, color)
      : _client.from('cart_items').update({'quantity': quantity}).match({
          'user_id': uid,
          'shoe_id': shoeId,
          'size': size,
          'color': color,
        });

  Future<void> removeFromCart(
    String uid,
    String shoeId,
    String size,
    String color,
  ) => _client.from('cart_items').delete().match({
    'user_id': uid,
    'shoe_id': shoeId,
    'size': size,
    'color': color,
  });

  Future<void> toggleWishlist(String uid, ShoeModel shoe) async {
    final existing = await _client.from('wishlist').select('shoe_id').match({
      'user_id': uid,
      'shoe_id': shoe.id,
    }).maybeSingle();
    if (existing == null) {
      await _client.from('wishlist').insert({
        'user_id': uid,
        'shoe_id': shoe.id,
      });
    } else {
      await _client.from('wishlist').delete().match({
        'user_id': uid,
        'shoe_id': shoe.id,
      });
    }
  }

  Future<String> placeOrder(
    String uid,
    List<CartItemModel> items,
    double total,
    String address,
  ) async {
    final order = await _client
        .from('orders')
        .insert({
          'user_id': uid,
          'items': items.map((item) => item.toMap(uid)).toList(),
          'total': total,
          'address': address,
          'status': 'Processing',
        })
        .select('id')
        .single();
    await _client.from('cart_items').delete().eq('user_id', uid);
    return order['id'] as String;
  }

  Stream<List<Map<String, dynamic>>> streamOrders(String uid) => _client
      .from('orders')
      .stream(primaryKey: ['id'])
      .eq('user_id', uid)
      .order('created_at', ascending: false);
}
