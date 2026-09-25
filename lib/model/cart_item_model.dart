import 'shoe_model.dart';

class CartItemModel {
  const CartItemModel({
    required this.shoe,
    required this.quantity,
    required this.selectedSize,
    required this.selectedColor,
  });

  final ShoeModel shoe;
  final int quantity;
  final String selectedSize;
  final String selectedColor;

  double get totalPrice => shoe.price * quantity;

  factory CartItemModel.fromMap(Map<String, dynamic> map, ShoeModel shoe) =>
      CartItemModel(
        shoe: shoe,
        quantity: (map['quantity'] as num?)?.toInt() ?? 1,
        selectedSize: map['size']?.toString() ?? '',
        selectedColor: map['color']?.toString() ?? '',
      );

  Map<String, dynamic> toMap(String uid) => {
    'user_id': uid,
    'shoe_id': shoe.id,
    'size': selectedSize,
    'color': selectedColor,
    'quantity': quantity,
  };
}
