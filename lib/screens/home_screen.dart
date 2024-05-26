import 'dart:developer';

import 'package:sql_data_fatch/screens/details_screen.dart';
import 'package:sql_data_fatch/sql/sql_helper.dart';
import 'package:sql_data_fatch/sql/sql_helper_details.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _sqlData = [];
  List<Map<String, dynamic>> _filteredData = [];
  bool _isLoading = true;
  String selectedItem = 'all';
  int _itemsToShow = 5;

  void _refreshSqlData() async {
    final data = await SQLHelper.getItemsWithDetails();
    setState(() {
      _sqlData = data;
      _applyFilter();
      _isLoading = false;
    });
  }

  void _applyFilter() {
    List<Map<String, dynamic>> filtered;
    if (selectedItem == 'all') {
      filtered = _sqlData;
    } else if (selectedItem == 'less') {
      filtered = _sqlData
          .where((journal) =>
              int.tryParse(journal['salary']) != null &&
              int.parse(journal['salary']) < 200)
          .toList();
    } else if (selectedItem == 'more') {
      filtered = _sqlData
          .where((journal) =>
              int.tryParse(journal['salary']) != null &&
              int.parse(journal['salary']) >= 200)
          .toList();
    } else {
      filtered = _sqlData;
    }

    if (selectedItem == 'all') {
      _filteredData = filtered.take(_itemsToShow).toList();
    } else {
      _filteredData = filtered;
    }
  }

  void _showMoreItems() {
    setState(() {
      _itemsToShow += 5;
      _applyFilter();
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshSqlData();
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();

  void _showForm(int? id) async {
    if (id != null) {
      final existingJournal =
          _sqlData.firstWhere((element) => element['id'] == id);
      _nameController.text = existingJournal['name'];
      _locationController.text = existingJournal['location'];
      _departmentController.text = existingJournal['department'] ?? '';
      _roleController.text = existingJournal['role'] ?? '';
      _salaryController.text = existingJournal['salary'] ?? '';
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(hintText: 'Name'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(hintText: 'Location'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _departmentController,
                    decoration: const InputDecoration(hintText: 'Department'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _roleController,
                    decoration: const InputDecoration(hintText: 'Role'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _salaryController,
                    decoration: const InputDecoration(hintText: 'Salary'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (id == null) {
                        await _addItem();
                      } else {
                        await _updateItem(id);
                      }
                      _nameController.text = '';
                      _locationController.text = '';
                      _departmentController.text = '';
                      _roleController.text = '';
                      _salaryController.text = '';
                      Navigator.of(context).pop();
                    },
                    child: Text(id == null ? 'Create New' : 'Update'),
                  )
                ],
              ),
            ));
  }

  Future<void> _addItem() async {
    int itemId = await SQLHelper.createItem(
        _nameController.text, _locationController.text);
    await SQLHelperDetails.createItem(_departmentController.text,
        _roleController.text, _salaryController.text, itemId);
    _refreshSqlData();
  }

  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(
        id, _nameController.text, _locationController.text);
    await SQLHelperDetails.updateItem(id, _departmentController.text,
        _roleController.text, _salaryController.text);
    _refreshSqlData();
  }

  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    await SQLHelperDetails.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a journal!'),
    ));
    _refreshSqlData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQL'),
        actions: [
          IconButton(
            onPressed: () async {
              await SQLHelper.deleteAllItems();
              await SQLHelperDetails.deleteAllDetails();
              _refreshSqlData();
            },
            icon: const Icon(Icons.folder_delete),
          ),
          PopupMenuButton(
            onSelected: (value) {
              setState(() {
                selectedItem = value.toString();
                _itemsToShow = 5; // Reset the items to show when filter changes
                _applyFilter();
              });
              log(value.toString());
            },
            itemBuilder: (BuildContext context) {
              return const [
                PopupMenuItem(
                  value: 'all',
                  child: Text("ALL"),
                ),
                PopupMenuItem(
                  value: 'less',
                  child: Text("less than 200"),
                ),
                PopupMenuItem(
                  value: 'more',
                  child: Text("more than 200"),
                )
              ];
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _filteredData.length + 1,
              itemBuilder: (context, index) {
                if (index < _filteredData.length) {
                  return Card(
                    color: Colors.grey[100],
                    margin:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: ListTile(
                      title: Text(_filteredData[index]['name']),
                      subtitle: Text(_filteredData[index]['location']),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  _showForm(_filteredData[index]['id']),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  _deleteItem(_filteredData[index]['id']),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ItemDetailPage(item: _filteredData[index]),
                          ),
                        );
                      },
                    ),
                  );
                } else if (selectedItem == 'all' &&
                    _filteredData.length < _sqlData.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 20),
                    child: ElevatedButton(
                      onPressed: _showMoreItems,
                      child: const Text('Show More'),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}
