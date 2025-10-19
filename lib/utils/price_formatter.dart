String formatPriceSmart(double price) {
  if (price % 1 == 0) {
    return price.toStringAsFixed(0); // Whole number like 12
  } else {
    return price.toStringAsFixed(2); // Decimal like 11.50
  }
}
