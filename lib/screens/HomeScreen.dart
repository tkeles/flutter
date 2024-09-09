import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'InvoiceDelivery.dart';  // InvoiceDelivery sayfasının dosya yolunu ekleyin
import 'LoginScreen.dart'; // LoginScreen sayfasının dosya yolunu ekleyin

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({required this.username});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String apiUrl = '';
  String firmNumber = '';
  String safeDepositCode = '';
  String erpUsername = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      apiUrl = prefs.getString('api_url') ?? 'Not set';
      firmNumber = prefs.getString('firm_number') ?? 'Not set';
      safeDepositCode = prefs.getString('safe_deposit_code') ?? 'Not set';
      erpUsername = prefs.getString('erp_username') ?? 'Not set';
    });
  }

  void _navigateToInvoiceDelivery(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InvoiceDeliveryScreen(username: widget.username)),
    );
  }

  void _navigateToLoginScreen(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _exitApp() {
    SystemNavigator.pop();
  }

  void _showUserInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('User Information'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Username: ${widget.username}'),
              Text('API URL: $apiUrl'),
              Text('Firm Number: $firmNumber'),
              Text('Safe Deposit Code: $safeDepositCode'),
              Text('ERP Username: $erpUsername'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ngen Delivex'),
        backgroundColor: Colors.blue, // AppBar başlık rengi mavi
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _showUserInfo(context),
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'logout') {
                _navigateToLoginScreen(context);
              } else if (result == 'exit') {
                _exitApp();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Выход из системы'),
              ),
              const PopupMenuItem<String>(
                value: 'exit',
                child: Text('Выход'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 20.0),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
              title: const Text(
                'Доставка счетов',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _navigateToInvoiceDelivery(context),
            ),
          ),
        ],
      ),
    );
  }
}
