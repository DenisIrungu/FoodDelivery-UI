class Foods {
  final String title;
  final String imagePath;
  final double price;
  final FoodCategory category;
  List<Addon> availableAddon;

  Foods({
    required this.title,
    required this.imagePath,
    required this.price,
    required this.category,
    required this.availableAddon
  });
}

enum FoodCategory {
  All,
  Featured,
  TopOfTheWeek,
  FastFood,
  Soup,
  Salad,
}


class Addon {
  String name;
  double price;

  Addon({required this.name, required this.price});
}
