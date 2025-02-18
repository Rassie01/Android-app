// lib/screens/add_item_screen.dart
import 'package:flutter/material.dart';
import '../services/database_helper.dart';

class AddItemScreen extends StatefulWidget {
  final Map<String, dynamic>? item;
  final bool isEditing;

  AddItemScreen({this.item, this.isEditing = false});

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  late String _name;
  late String _url;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.item != null) {
      _type = widget.item!['type'];
      _name = widget.item!['name'];
      _url = widget.item!['url'];
    } else {
      _type = 'server';
      _name = '';
      _url = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditing ? 'Edit Item' : 'Add New Item')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _type,
                items: ['server', 'api'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _type = newValue!;
                  });
                },
                decoration: InputDecoration(labelText: 'Type'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a type';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (value) {
                  _name = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _url,
                decoration: InputDecoration(labelText: 'URL/IP Address'),
                onChanged: (value) {
                  _url = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a URL or IP address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (widget.isEditing) {
                      await DatabaseHelper.instance.updateItem({
                        'id': widget.item!['id'],
                        'type': _type,
                        'name': _name,
                        'url': _url,
                      });
                    } else {
                      await DatabaseHelper.instance.insertItem({
                        'type': _type,
                        'name': _name,
                        'url': _url,
                      });
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(widget.isEditing ? 'Update' : 'Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}