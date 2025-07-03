import 'package:shlih_kitchen/models/foods.dart';

class CartItem {
  Foods food;
  List<Addon> selectedAddons;
  int quantity;

  CartItem({
    required this.food,
    required this.selectedAddons,
    this.quantity = 1,
  });

  double get totalPrice {
    double addonPrice =
        selectedAddons.fold(0, (sum, Addon) => sum + Addon.price);
    return (food.price + addonPrice) * quantity;
  }
}
