import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_1/data/categories.dart';
import 'package:shop_1/data/widgets/new_item.dart';
import 'package:shop_1/models/category.dart';
import 'package:shop_1/models/grocery_item.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isLoading = false;

  String? _error;
  List<GroceryItem> _groceryItems = [];
  _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null; // Clear any previous errors
      });

      final url = Uri.https(
          'your-project-id.firebaseio.com', 'your-database-path.json');

      final response = await http.get(url);

      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Failed to fetch data, please try again.';
          _isLoading = false;
        });
        return; // Exit early if there's an error
      }

      final data = json.decode(response.body);

      // If the data is null or empty, set the list to empty
      if (data == null) {
        setState(() {
          _groceryItems = [];
          _isLoading = false;
        });
        return;
      }

      List<GroceryItem> loadedGroceryItems = [];

      // Parse the loaded data and populate the grocery items
      final Map<String, dynamic> loadedData = data;
      for (var item in loadedData.entries) {
        final Category category = categories.entries
            .firstWhere(
                (element) => element.value.title == item.value['category'])
            .value;
        loadedGroceryItems.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ));
      }

      setState(() {
        _groceryItems = loadedGroceryItems;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Something went wrong. Please try again later.';
        _isLoading = false;
      });
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    final url = Uri.https('your-project-id.firebaseio.com',
        'your-database-path.json'); // Adjust the URL path as needed

    final response = await http.delete(url);

    if (response.statusCode == 200) {
      print('Category deleted successfully');
    } else {
      print('Failed to delete category. Status code: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context)
                    .push<GroceryItem>(
                  MaterialPageRoute(
                    builder: (context) => NewItem(),
                  ),
                )
                    .then((GroceryItem? item) {
                  if (item != null) {
                    setState(() {
                      _groceryItems.add(item);
                    });
                  }
                });
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Text('...Loading'),
            )
          : _error != null
              ? Center(child: Text('$_error'))
              : _groceryItems.isEmpty
                  ? Center(
                      child: Text('No items added'),
                    )
                  : ListView.builder(
                      itemCount: _groceryItems.length,
                      itemBuilder: (ctx, index) {
                        return Dismissible(
                          background: Container(
                            color: Colors.green, // Full background color
                            alignment: Alignment
                                .centerLeft, // Align the icon to the right
                            padding: EdgeInsets.symmetric(
                                horizontal: 20), // Padding for the icon
                            child: Icon(
                              Icons.edit,
                              color: Colors
                                  .white, // White icon for better visibility on red background
                            ),
                          ),
                          secondaryBackground: Container(
                            color: Colors.red, // Full background color
                            alignment: Alignment
                                .centerRight, // Align the icon to the right
                            padding: EdgeInsets.symmetric(
                                horizontal: 20), // Padding for the icon
                            child: Icon(
                              Icons.delete,
                              color: Colors
                                  .white, // White icon for better visibility on red background
                            ),
                          ),
                          key: ValueKey(_groceryItems[index].id),
                          direction: DismissDirection
                              .horizontal, // Allow horizontal swipe (left and right)
                          onDismissed: (DismissDirection direction) async {
                            if (direction == DismissDirection.endToStart) {
                              // User swiped left (endToStart)
                              await deleteCategory(_groceryItems[index].id);
                              setState(() {
                                _groceryItems.remove(_groceryItems[index]);
                              }); // Call function to delete the item
                            } else if (direction ==
                                DismissDirection.startToEnd) {
                              await Navigator.push<Future>(
                                  context,
                                  MaterialPageRoute(
                                      builder: (ctx) => NewItem.Edit(
                                            name: _groceryItems[index].name,
                                            isEdit: true,
                                            quantity:
                                                _groceryItems[index].quantity,
                                            category:
                                                _groceryItems[index].category,
                                            id: _groceryItems[index].id,
                                          ))).then((v) {
                                _loadData();
                              });
                            }
                          },
                          child: ListTile(
                            leading: Container(
                              height: 24,
                              width: 24,
                              color: _groceryItems[index].category.color,
                            ),
                            title: Text(_groceryItems[index].name),
                            trailing: Text('${_groceryItems[index].quantity}'),
                            subtitle: Text(_groceryItems[index].category.title),
                          ),
                        );
                      }),
    );
  }
}
