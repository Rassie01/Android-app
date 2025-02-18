// lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../services/network_helper.dart';
import 'add_item_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Map<String, dynamic>> servers = [];
  List<Map<String, dynamic>> apis = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await DatabaseHelper.instance.getAllItems();
    setState(() {
      servers = data.where((item) => item['type'] == 'server').toList();
      apis = data.where((item) => item['type'] == 'api').toList();
    });
  }

  Future<void> _testConnections() async {
    for (int i = 0; i < servers.length; i++) {
      final server = Map<String, dynamic>.from(servers[i]);
      final status = await NetworkHelper.pingServer(server['url']);
      setState(() {
        server['status'] = status ? 'Online' : 'Offline';
        servers[i] = server;
      });
    }
    for (int i = 0; i < apis.length; i++) {
      final api = Map<String, dynamic>.from(apis[i]);
      final status = await NetworkHelper.checkApi(api['url']);
      setState(() {
        api['status'] = status ? 'Online' : 'Offline';
        apis[i] = api;
      });
    }
  }

  Future<void> _deleteItem(int id) async {
    await DatabaseHelper.instance.deleteItem(id);
    _loadData();
  }

  Future<void> _editItem(Map<String, dynamic> item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddItemScreen(
          item: item,
          isEditing: true,
        ),
      ),
    );
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('API & Server Tester'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade100, Colors.orange.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(child: _buildTable('Servers', servers)),
            Expanded(child: _buildTable('APIs', apis)),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddItemScreen()),
              );
              _loadData();
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.orangeAccent,
          ),
          SizedBox(width: 10),
          FloatingActionButton(
            heroTag: 'refresh',
            onPressed: _testConnections,
            child: Icon(Icons.refresh),
            backgroundColor: Colors.orangeAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildTable(String title, List<Map<String, dynamic>> items) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange.shade800),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(item['name']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item['status'] ?? 'Unknown',
                        style: TextStyle(
                          color: item['status'] == 'Online' ? Colors.green : Colors.red,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          await _editItem(item);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _deleteItem(item['id']);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}