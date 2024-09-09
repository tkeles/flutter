import 'package:flutter/material.dart';
import 'package:ngen_delivex/models/Driver.dart';
import 'package:ngen_delivex/services/ApiService.dart';
import 'package:ngen_delivex/services/InvoiceService.dart';

class DriverSelectionScreen extends StatefulWidget {
  final Function(Driver) onDriverSelected;

  const DriverSelectionScreen({super.key, required this.onDriverSelected});

  @override
  _DriverSelectionScreenState createState() => _DriverSelectionScreenState();
}

class _DriverSelectionScreenState extends State<DriverSelectionScreen> {
  List<Driver> _drivers = [];
  List<Driver> _filteredDrivers = [];
  TextEditingController _searchController = TextEditingController();
  final InvoiceService _invoiceService = InvoiceService(ApiService());

  @override
  void initState() {
    super.initState();
    _loadDrivers();
    _searchController.addListener(_filterDrivers);
  }

  Future<void> _loadDrivers() async {
    try {
      List<Driver> drivers = await _invoiceService.getDrivers();
      setState(() {
        _drivers = drivers;
        _filteredDrivers = drivers;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Не удалось загрузить водителей: $e')));
    }
  }

  void _filterDrivers() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDrivers = _drivers.where((driver) {
        return driver.driverName.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Выберите водителя'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Поиск водителя',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredDrivers.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_filteredDrivers[index].driverName),
                  onTap: () {
                    widget.onDriverSelected(_filteredDrivers[index]);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
