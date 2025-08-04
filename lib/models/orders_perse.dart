class OrderItem {
  final int quantity;
  final String name;
  final List<String> addons;

  OrderItem({
    required this.quantity,
    required this.name,
    required this.addons,
  });

  @override
  String toString() {
    return 'OrderItem(quantity: $quantity, name: $name, addons: $addons)';
  }
}

class ParsedOrder {
  final List<OrderItem> items;
  final String totalPrice;
  final String deliveryAddress;
  final String orderDate;
  final int totalItemCount;

  ParsedOrder({
    required this.items,
    required this.totalPrice,
    required this.deliveryAddress,
    required this.orderDate,
    required this.totalItemCount,
  });

  @override
  String toString() {
    return 'ParsedOrder(items: $items, totalPrice: $totalPrice, deliveryAddress: $deliveryAddress, orderDate: $orderDate, totalItemCount: $totalItemCount)';
  }
}

class OrderParser {
  static ParsedOrder parseReceipt(String receipt) {
    final lines = receipt.split('\n');
    List<OrderItem> items = [];
    String totalPrice = '';
    String deliveryAddress = '';
    String orderDate = '';
    int totalItemCount = 0;

    String? currentItemName;
    int currentItemQuantity = 0;
    List<String> currentAddons = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      
      if (line.isEmpty) continue;

      // Extract date (should be in format: yyyy-mm-dd HH:mm:ss)
      if (_isDateLine(line)) {
        orderDate = line;
        continue;
      }

      // Skip decorative lines
      if (line.startsWith('_') || line == 'Here is your receipt.') {
        continue;
      }

      // Parse item lines (format: "quantity* item_name")
      if (line.contains('*') && !line.startsWith('Add-ons:')) {
        // Save previous item if exists
        if (currentItemName != null) {
          items.add(OrderItem(
            quantity: currentItemQuantity,
            name: currentItemName,
            addons: List.from(currentAddons),
          ));
        }

        // Parse new item
        final parts = line.split('*');
        if (parts.length >= 2) {
          currentItemQuantity = int.tryParse(parts[0].trim()) ?? 1;
          currentItemName = parts[1].trim();
          currentAddons.clear();
        }
        continue;
      }

      // Parse add-ons line (format: "Add-ons: addon1 (price), addon2 (price)")
      if (line.startsWith('Add-ons:')) {
        final addonsText = line.substring('Add-ons:'.length).trim();
        currentAddons = _parseAddons(addonsText);
        continue;
      }

      // Parse total cost (format: "Total cost:X")
      if (line.startsWith('Total cost:')) {
        final costText = line.substring('Total cost:'.length).trim();
        totalItemCount = int.tryParse(costText) ?? 0;
        continue;
      }

      // Parse total price (format: "Total price: $XX.XX")
      if (line.startsWith('Total price:')) {
        totalPrice = line.substring('Total price:'.length).trim();
        continue;
      }

      // Parse delivery address (format: "Delivering to: address")
      if (line.startsWith('Delivering to:')) {
        deliveryAddress = line.substring('Delivering to:'.length).trim();
        continue;
      }
    }

    // Don't forget to add the last item
    if (currentItemName != null) {
      items.add(OrderItem(
        quantity: currentItemQuantity,
        name: currentItemName,
        addons: List.from(currentAddons),
      ));
    }

    return ParsedOrder(
      items: items,
      totalPrice: totalPrice,
      deliveryAddress: deliveryAddress,
      orderDate: orderDate,
      totalItemCount: totalItemCount,
    );
  }

  // Helper method to check if a line is a date
  static bool _isDateLine(String line) {
    // Check for format: yyyy-mm-dd HH:mm:ss
    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$');
    return dateRegex.hasMatch(line);
  }

  // Helper method to parse add-ons from the add-ons line
  static List<String> _parseAddons(String addonsText) {
    if (addonsText.isEmpty) return [];

    // Split by comma and extract addon names
    final addonParts = addonsText.split(',');
    List<String> addons = [];

    for (final part in addonParts) {
      final trimmed = part.trim();
      if (trimmed.isNotEmpty) {
        // Extract addon name before the price (remove everything after and including '(')
        final nameMatch = RegExp(r'^([^(]+)').firstMatch(trimmed);
        if (nameMatch != null) {
          final addonName = nameMatch.group(1)?.trim();
          if (addonName != null && addonName.isNotEmpty) {
            addons.add(addonName);
          }
        }
      }
    }

    return addons;
  }

  // Helper method to format order items for display
  static String formatOrderItems(List<OrderItem> items) {
    if (items.isEmpty) return 'No items';

    final buffer = StringBuffer();
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      buffer.write('${item.quantity}x ${item.name}');
      
      if (item.addons.isNotEmpty) {
        buffer.write(' (${item.addons.join(', ')})');
      }
      
      if (i < items.length - 1) {
        buffer.write('\n');
      }
    }
    return buffer.toString();
  }

  // Helper method to get formatted delivery time
  static String getFormattedDeliveryTime(DateTime estimatedDeliveryTime) {
    final now = DateTime.now();
    final difference = estimatedDeliveryTime.difference(now);
    
    if (difference.isNegative) {
      return 'Delivered';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min';
    } else {
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;
      return '${hours}h ${minutes}m';
    }
  }

  // Helper method to format order date
  static String formatOrderDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today ${_formatTime(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${_formatTime(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // Helper method to format time
  static String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}