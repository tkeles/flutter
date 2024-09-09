// ignore: file_names
// ignore: file_names
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _firmNumberController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _safeDepositCodeController = TextEditingController();
  final TextEditingController _erpUsernameController = TextEditingController();
  final TextEditingController _erpUserPasswordController = TextEditingController();
  bool _isPasswordVisible = false; // Şifre alanı görünürlüğü kontrolü
  bool _isErpPasswordVisible = false; // ERP şifre alanı görünürlüğü kontrolü

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _urlController.text = prefs.getString('api_url') ?? '';
      _firmNumberController.text = prefs.getString('firm_number') ?? '';
      _usernameController.text = prefs.getString('username') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
      _safeDepositCodeController.text = prefs.getString('safe_deposit_code') ?? '';
      _erpUsernameController.text = prefs.getString('erp_username') ?? '';
      _erpUserPasswordController.text = prefs.getString('erp_userpassword') ?? '';
    });
  }

  void _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_url', _urlController.text);
    await prefs.setString('firm_number', _firmNumberController.text);
    await prefs.setString('username', _usernameController.text);
    await prefs.setString('password', _passwordController.text);
    await prefs.setString('safe_deposit_code', _safeDepositCodeController.text);
    await prefs.setString('erp_username', _erpUsernameController.text);
    await prefs.setString('erp_userpassword', _erpUserPasswordController.text);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(labelText: 'REST Service URL'),
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: _firmNumberController,
                decoration: const InputDecoration(labelText: 'Firm Number'),
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isPasswordVisible, // Şifreyi gizler
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: _safeDepositCodeController,
                decoration: const InputDecoration(labelText: 'Safe Deposit Code'),
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: _erpUsernameController,
                decoration: const InputDecoration(labelText: 'ERP Username'),
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: _erpUserPasswordController,
                decoration: InputDecoration(
                  labelText: 'ERP User Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isErpPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isErpPasswordVisible = !_isErpPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isErpPasswordVisible, // Şifreyi gizler
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _saveSettings,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}