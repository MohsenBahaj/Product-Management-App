// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:shop_1/models/category.dart';

class GroceryItem {
  String id;
  String name;
  int quantity;
  Category category;
  GroceryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.category,
  });
}
