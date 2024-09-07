import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_1/data/categories.dart';
import 'package:shop_1/models/category.dart';
import 'package:shop_1/models/grocery_item.dart';
import 'package:http/http.dart' as http;

class NewItem extends StatefulWidget {
  String name = '';
  int quantity = 1;
  var category = categories[Categories.fruite]!;
  bool isEdit = false;
  String? id;
  NewItem.Edit(
      {super.key,
      required this.id,
      required this.name,
      required this.isEdit,
      required this.quantity,
      required this.category});
  NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  bool _isLoading = false;

  Future<void> editItem(String categoryId) async {
    final valid = formKey.currentState!.validate();
    if (valid) {
      formKey.currentState!.save();
      final url = Uri.https('your-project-id.firebaseio.com',
          'your-database-path.json'); // Adjust the URL based on your Firebase structure
      print(categoryId);
      print('Name: ${widget.name}');
      print('Quantity: ${widget.quantity}');
      print('Category: ${widget.category.title}');

      try {
        setState(() {
          _isLoading = true;
        });
        final response = await http.patch(url,
            headers: {
              "Content-Type": "application/json",
            },
            body: json.encode({
              'name': widget.name,
              'quantity': widget.quantity,
              'category': widget.category.title
            }));
        setState(() {
          _isLoading = false;
          Navigator.of(context).pop();
        });
        if (response.statusCode == 200) {
          print('Item updated successfully');
        } else {
          print('Failed to update item. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error occurred: $e');
      }
    }
  }

  addItem() async {
    final valid = formKey.currentState!.validate();
    if (valid) {
      formKey.currentState!.save();

      try {
        setState(() {
          _isLoading = true;
        });
        final url = Uri.https(
            'your-project-id.firebaseio.com', 'your-database-path.json');
        final response = await http.post(url,
            headers: {"content-Type": "application/json"},
            body: json.encode({
              'name': widget.name,
              'quantity': widget.quantity,
              'category': widget.category.title
            }));
        setState(() {
          _isLoading = false;
        });
        if (response.statusCode == 200) {
          final res = json.decode(response.body);

          Navigator.of(context).pop(GroceryItem(
              id: res['name'],
              name: widget.name!,
              quantity: widget.quantity,
              category: widget.category));
        }
      } catch (e) {
        print(e);
      }
    }
  }

  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit' : 'New Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(9),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: widget.name,
                onSaved: (newValue) {
                  widget.name = newValue!;
                },
                maxLength: 50,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name is required';
                  } else if (value.trim().isEmpty || value.trim().length > 50) {
                    return "Name should be between 1 and 50 characters";
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  // Expanded TextFormField for quantity
                  Expanded(
                    child: TextFormField(
                      onSaved: (newValue) {
                        widget.quantity = int.parse(newValue!);
                      },
                      validator: (String? value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Please Enter valid quantity';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      initialValue: widget.quantity.toString() ?? '1',
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  // Expanded DropdownButton for categories
                  Expanded(
                    child: DropdownButtonFormField(
                      value: widget.category,
                      isExpanded: true,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  height: 16,
                                  width: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Text(category.value.title),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (choice) {
                        setState(() {
                          widget.category = choice!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      formKey.currentState!.reset();
                    },
                    style: const ButtonStyle(
                        foregroundColor: WidgetStatePropertyAll(Colors.white)),
                    child: const Text('Reset'),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                      style: const ButtonStyle(
                          foregroundColor:
                              WidgetStatePropertyAll(Colors.white)),
                      onPressed: () async {
                        if (widget.isEdit) {
                          editItem(widget.id!);
                          return;
                        } else {
                          addItem();
                        }
                      },
                      child: _isLoading
                          ? Text('...')
                          : widget.isEdit
                              ? Text('Edit ${widget.name}')
                              : Text('Add Item')),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
