import 'dart:ui';

enum Categories {
  vegetables,
  fruite,
  meat,
  dairy,
  carbs,
  sweets,
  spices,
  convenience,
  hygiene,
  other
}

class Category {
  final String title;
  final Color color;

  Category(this.title, this.color);
}
