// restaurant.dart

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shlih_kitchen/models/cart_item.dart';
import 'package:shlih_kitchen/models/foods.dart';

class Restaurant extends ChangeNotifier {
  final List<Foods> _menu = [
    Foods(
      title: 'African Brown Ugali',
      imagePath: 'assets/brownugali.jpg',
      price: 14.99,
      category: FoodCategory.Featured,
      availableAddon: [
        Addon(name: 'Chicken wing', price: 6.00),
        Addon(name: 'Greens', price: 1.00),
        Addon(name: 'Milk', price: 2.00)
      ],
    ),
    Foods(
      title: 'Chapati Beef',
      imagePath: 'assets/ChapatiBeef.jpg',
      price: 1.00,
      category: FoodCategory.Featured,
      availableAddon: [
        Addon(name: 'Spicy sauce', price: 1.00),
        Addon(name: 'Extra beef', price: 1.00),
        Addon(name: 'Juice', price: 2.00)
      ],
    ),
    Foods(
      title: 'Githeri',
      imagePath: 'assets/Githeri.jpg',
      price: 17.99,
      category: FoodCategory.Featured,
      availableAddon: [
        Addon(name: 'Avocado slices', price: 1.00),
        Addon(name: 'Boiled eggs', price: 1.00),
        Addon(name: 'Spicy chili relish', price: 1.00)
      ],
    ),
    Foods(
      title: 'Jollof Rice',
      imagePath: 'assets/JolloRice.jpg',
      price: 17.99,
      category: FoodCategory.TopOfTheWeek,
      availableAddon: [
        Addon(name: 'Fried plantains', price: 1.00),
        Addon(name: 'Grilled chicken', price: 4.00),
        Addon(name: 'Shito', price: 1.00)
      ],
    ),
    Foods(
      title: 'Zambian Nshima Fish',
      imagePath: 'assets/ZambianNshimaFishwithVeggies.jpg',
      price: 20.99,
      category: FoodCategory.TopOfTheWeek,
      availableAddon: [
        Addon(name: 'Collard greens', price: 1.00),
        Addon(name: 'Tomato gravy', price: 1.50),
        Addon(name: 'Extra Nshima', price: 1.00)
      ],
    ),
    Foods(
      title: 'Fried Fish with White Rice',
      imagePath: 'assets/FriedFishwithwhiteRice.jpg',
      price: 18.99,
      category: FoodCategory.TopOfTheWeek,
      availableAddon: [
        Addon(name: 'Coconut sauce', price: 1.00),
        Addon(name: 'Sliced lemon', price: 1.50),
        Addon(name: 'Kachumbari', price: 1.00)
      ],
    ),
    Foods(
      title: 'East African Pilau',
      imagePath: 'assets/pilau.jpg',
      price: 10.99,
      category: FoodCategory.Featured,
      availableAddon: [
        Addon(name: 'Raita', price: 1.00),
        Addon(name: 'Fried onions', price: 1.50),
        Addon(name: 'Roasted potatoes', price: 1.00)
      ],
    ),
    Foods(
      title: 'Chips Masala',
      imagePath: 'assets/ChipsMasala.jpg',
      price: 10.99,
      category: FoodCategory.Featured,
      availableAddon: [
        Addon(name: 'Sausage slices', price: 1.00),
        Addon(name: 'Cheese topping', price: 1.50),
        Addon(name: 'Extra masala spices', price: 1.00)
      ],
    ),
    Foods(
      title: 'Chicken Teriyaki',
      imagePath: 'assets/chickenTeriyaki.jpg',
      price: 10.99,
      category: FoodCategory.TopOfTheWeek,
      availableAddon: [
        Addon(name: 'Sesame seeds', price: 1.00),
        Addon(name: 'Extra teriyaki sauce', price: 1.50),
        Addon(name: 'Steamed veggies', price: 1.00)
      ],
    ),
    Foods(
      title: 'Heavy Breakfast',
      imagePath: 'assets/f1.jpg',
      price: 10.99,
      category: FoodCategory.FastFood,
      availableAddon: [
        Addon(name: 'Bacon strips', price: 1.00),
        Addon(name: 'Hash browns', price: 1.50),
        Addon(name: 'Pancakes', price: 1.00)
      ],
    ),
    Foods(
      title: 'Gourmet Hot Dog',
      imagePath: 'assets/f2.jpg',
      price: 10.99,
      category: FoodCategory.FastFood,
      availableAddon: [
        Addon(name: 'Caramelized onions', price: 1.00),
        Addon(name: 'Cheese sauce', price: 1.50),
        Addon(name: 'Pickles', price: 1.00)
      ],
    ),
    Foods(
      title: 'Gourmet Steak Dish',
      imagePath: 'assets/f3.jpg',
      price: 10.99,
      category: FoodCategory.Featured,
      availableAddon: [
        Addon(name: 'Garlic butter', price: 1.00),
        Addon(name: 'Grilled vegetables', price: 1.50),
        Addon(name: 'Mashed potatoes', price: 1.00)
      ],
    ),
    Foods(
      title: 'Osso Buco',
      imagePath: 'assets/f4.jpg',
      price: 10.99,
      category: FoodCategory.TopOfTheWeek,
      availableAddon: [
        Addon(name: 'Creamy polenta', price: 1.00),
        Addon(name: 'Garlic bread', price: 1.50),
        Addon(name: 'Fresh herbs', price: 1.00)
      ],
    ),
    Foods(
      title: 'Loaded Hot Dog',
      imagePath: 'assets/f5.jpg',
      price: 15.99,
      category: FoodCategory.FastFood,
      availableAddon: [
        Addon(name: 'Jalapeños', price: 1.00),
        Addon(name: 'Mustard & ketchup mix', price: 1.50),
        Addon(name: 'Crispy bacon', price: 1.00)
      ],
    ),
    Foods(
      title: 'Rice Chicken',
      imagePath: 'assets/f6.jpg',
      price: 15.99,
      category: FoodCategory.Featured,
      availableAddon: [
        Addon(name: 'Curry sauce', price: 1.00),
        Addon(name: 'Steamed broccoli', price: 1.50),
        Addon(name: 'Fried plantain', price: 1.00)
      ],
    ),
    Foods(
      title: 'Hungarian Goulash',
      imagePath: 'assets/f7.jpg',
      price: 25.99,
      category: FoodCategory.Soup,
      availableAddon: [
        Addon(name: 'Sour cream', price: 1.00),
        Addon(name: 'Crusty bread', price: 1.50),
        Addon(name: 'Potato cubes', price: 1.00)
      ],
    ),
    Foods(
      title: 'African Beef Stew with Rice',
      imagePath: 'assets/f8.jpg',
      price: 15.99,
      category: FoodCategory.Soup,
      availableAddon: [
        Addon(name: 'Sukuma wiki', price: 1.00),
        Addon(name: 'Extra stew', price: 1.50),
        Addon(name: 'Fresh chili', price: 1.00)
      ],
    ),
    Foods(
      title: 'Asian Fried Rice',
      imagePath: 'assets/favfood1.jpg',
      price: 25.99,
      category: FoodCategory.FastFood,
      availableAddon: [
        Addon(name: 'Spring rolls', price: 1.00),
        Addon(name: 'Soy sauce dip', price: 1.50),
        Addon(name: 'Chili oil', price: 1.00)
      ],
    ),
    Foods(
      title: 'Hamburger',
      imagePath: 'assets/favfood2.jpg',
      price: 15.99,
      category: FoodCategory.FastFood,
      availableAddon: [
        Addon(name: 'Cheese slice', price: 1.00),
        Addon(name: 'Egg', price: 1.50),
        Addon(name: 'Extra patty', price: 1.00)
      ],
    ),
    Foods(
      title: 'Mutton Shawarma',
      imagePath: 'assets/favfood3.jpg',
      price: 10.99,
      category: FoodCategory.FastFood,
      availableAddon: [
        Addon(name: 'Garlic sauce', price: 1.00),
        Addon(name: 'Pickled vegetables', price: 1.50),
        Addon(name: 'Extra meat', price: 1.00)
      ],
    ),
    Foods(
      title: 'All in One',
      imagePath: 'assets/favfood4.jpg',
      price: 45.99,
      category: FoodCategory.FastFood,
      availableAddon: [
        Addon(name: 'Extra cheese', price: 1.00),
        Addon(name: 'Mixed grill add-on', price: 1.50),
        Addon(name: 'Large fries', price: 1.00)
      ],
    ),
  ];

  // Private cart list
  final List<CartItem> _cart = [];
  //Delivery address(Which user can change/update)
  String _deliveryAddress = 'Uhuru Street no 14, Damba';

  // Getters
  List<Foods> get menu => _menu;
  List<CartItem> get cart => _cart;
  String get deliveryAddress => _deliveryAddress;

  // Get menu items by category
  List<Foods> getMenuByCategory(FoodCategory category) {
    return _menu.where((food) => food.category == category).toList();
  }

  // Search menu items
  List<Foods> searchMenu(String query) {
    return _menu
        .where((food) => food.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Add to Cart
  void addToCart(Foods food, List<Addon> selectedAddon, {int quantity = 1}) {
    CartItem? cartItem = _cart.firstWhereOrNull((item) {
      // Check if food items are the same
      bool isSameFood = item.food == food;
      // Check if the selected addons are the same
      bool isSameAddons =
          ListEquality().equals(item.selectedAddons, selectedAddon);
      return isSameFood && isSameAddons;
    });

    // If item already exists, increment quantity
    if (cartItem != null) {
      cartItem.quantity += quantity;
    } else {
      // Otherwise add new cart item to cart
      _cart.add(CartItem(
        food: food,
        quantity: quantity,
        selectedAddons: selectedAddon,
      ));
    }
    notifyListeners();
  }

  //Update the delivery address
  void updateDeliveryAddress(String newAddress) {
    _deliveryAddress = newAddress;
    notifyListeners();
  }

  // Remove from the cart
  void removeFromCart(CartItem cartItem) {
    int cartIndex = _cart.indexOf(cartItem);

    if (cartIndex != -1) {
      if (_cart[cartIndex].quantity > 1) {
        _cart[cartIndex].quantity--;
      } else {
        _cart.removeAt(cartIndex);
      }
    }
    notifyListeners();
  }

  // Update cart item quantity directly
  void updateCartItemQuantity(CartItem cartItem, int newQuantity) {
    int cartIndex = _cart.indexOf(cartItem);

    if (cartIndex != -1) {
      if (newQuantity <= 0) {
        _cart.removeAt(cartIndex);
      } else {
        _cart[cartIndex].quantity = newQuantity;
      }
      notifyListeners();
    }
  }

  // Get total price
  double getTotalPrice() {
    return _cart.fold(0.0, (total, cartItem) {
      double itemTotal = cartItem.food.price;

      // Add addon prices
      for (Addon addon in cartItem.selectedAddons) {
        itemTotal += addon.price;
      }

      return total + (itemTotal * cartItem.quantity);
    });
  }

  // Get total number of items in cart
  int getTotalItemCount() {
    return _cart.fold(
        0, (totalCount, cartItem) => totalCount + cartItem.quantity);
  }

  // Get cart subtotal (before tax/delivery)
  double getSubtotal() {
    return getTotalPrice();
  }

  // Calculate tax (example: 8.5%)
  double getTax() {
    return getTotalPrice() * 0.085;
  }

  // Calculate delivery fee
  double getDeliveryFee() {
    return getTotalPrice() > 30.0 ? 0.0 : 3.99; // Free delivery over $30
  }

  // Get final total with tax and delivery
  double getFinalTotal() {
    return getTotalPrice() + getTax() + getDeliveryFee();
  }

  // Check if cart is empty
  bool get isCartEmpty => _cart.isEmpty;

  // Clear the cart
  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  // Get cart item count for specific food
  int getCartItemCount(Foods food) {
    return _cart
        .where((item) => item.food == food)
        .fold(0, (count, item) => count + item.quantity);
  }

  //Generate receipt
  String displayCartReceipt() {
    final receipt = StringBuffer();
    receipt.writeln('Here is your receipt.');
    receipt.writeln();

    //Format the date to include up to seconds only
    String formattedDate =
        DateFormat('yyyy-mm-dd HH:mm:ss').format(DateTime.now());

    receipt.writeln(formattedDate);
    receipt.writeln();
    receipt.writeln('_____________');

    for (final CartItem in _cart) {
      receipt.writeln('${CartItem.quantity}* ${CartItem.food.title}');
      if (CartItem.selectedAddons.isNotEmpty) {
        receipt.writeln('Add-ons: ${_formatAddons(CartItem.selectedAddons)}');
      }
      receipt.writeln();
    }
    receipt.writeln('___________');
    receipt.writeln();
    receipt.writeln('Total cost:${getTotalItemCount()}');
    receipt.writeln('Total price: ${_formatPrice(getTotalPrice())}');
    receipt.write('Delivering to: $deliveryAddress');

    return receipt.toString();
  }

  //Format double value into money
  String _formatPrice(double price) {
    return '\$${price.toStringAsFixed(2)}';
  }

  //Format list of addons into a string summary
  String _formatAddons(List<Addon> addons) {
    return addons
        .map((Addon) => '${Addon.name} (${_formatPrice(Addon.price)})')
        .join(',');
  }
}
