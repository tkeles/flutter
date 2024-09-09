import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ngen_delivex/models/Driver.dart';
import 'package:ngen_delivex/models/Parameter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ngen_delivex/models/InvoiceDto.dart';

import '../models/reason.dart';

class ApiService {
  late String _baseUrl;
  String? _firmNumber;

  ApiService() {
    _initializeBaseUrl();
  }

  Future<void> _initializeBaseUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? apiUrl = prefs.getString('api_url');
    _firmNumber = prefs.getString('firm_number');
    if (apiUrl != null && apiUrl.isNotEmpty) {
      _baseUrl = apiUrl;
    } else {
      _baseUrl = 'http://default-url/api';
    }
  }

  Future<String> authenticate(String username, String password) async {
    await _initializeBaseUrl();

    final url = Uri.parse('$_baseUrl/authenticate?username=$username&password=$password');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final user = jsonDecode(response.body);
        if (user != null) {
          return 'success';
        } else {
          return 'Пользователь с предоставленными учетными данными не найден.';
        }
      } else {
        return 'Аутентификация не удалась. Код состояния: ${response.statusCode}';
      }
    } catch (e) {
      return 'Exception occurred during authentication: $e';
    }
  }

  Future<List<InvoiceDto>> getInvoices(String username, {String? status, String? invoiceDate}) async {
    await _initializeBaseUrl();
    String url = '$_baseUrl/api/invoices?specode=$username';

    if (status != null && status.isNotEmpty) {
      url += '&status=$status';
    }

    if (_firmNumber != null && _firmNumber!.isNotEmpty) {
      url += '&firmnumber=$_firmNumber';
    }

    if (invoiceDate != null && invoiceDate.isNotEmpty) {
      url += '&invoicedate=$invoiceDate';
    }


    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((invoice) => InvoiceDto.fromJson(invoice)).toList();
    } else {
      throw Exception('Не удалось загрузить накладной. Код состояния: ${response.statusCode}, Body: ${response.body}');
    }
  }


  Future<List<Reason>> getReasons() async {
    await _initializeBaseUrl();
    String url = '$_baseUrl/api/Invoices/reasons';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((reason) => Reason.fromJson(reason)).toList();
    } else {
      throw Exception('Не удалось загрузить причины. Код состояния: ${response.statusCode}, Body: ${response.body}');
    }
  }


  Future<List<Driver>> getDrivers() async {
    await _initializeBaseUrl();
    String url = '$_baseUrl/api/Invoices/drivers';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((driver) => Driver.fromJson(driver)).toList();
    } else {
      throw Exception('Не удалось загрузить список водителей. Код состояния: ${response.statusCode}, Body: ${response.body}');
    }
  }

  Future<bool> updateInvoiceStatus(int invoiceRef, String status) async {
    await _initializeBaseUrl();
    String url = '$_baseUrl/api/Invoices/UpdateInvoiceStatus?invoiceRef=$invoiceRef&firmnumber=${_firmNumber ?? ''}&status=$status';

    print(url);

    final response = await http.post(Uri.parse(url));

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Не удалось обновить статус накладной. Код состояния: ${response.statusCode}, Body: ${response.body}');
    }
  }
  Future<bool> updateInvoiceStatusWithReason(int invoiceRef, String status, String reason) async {
    await _initializeBaseUrl();
    String url = '$_baseUrl/api/Invoices/UpdateInvoiceStatusWithReason?invoiceRef=$invoiceRef&firmnumber=${_firmNumber ?? ''}&status=$status&reason=${Uri.encodeComponent(reason)}';

    final response = await http.post(Uri.parse(url));

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Не удалось обновить статус накладной с причиной. Код состояния: ${response.statusCode}, Body: ${response.body}');
    }
  }
  Future<Parameter> getParameter(String type) async {
    await _initializeBaseUrl();
    String url = '$_baseUrl/api/Invoices/parameters?type=$type';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      return Parameter.fromJson(jsonResponse);
    } else {
      throw Exception('Не удалось загрузить параметры. Код состояния: ${response.statusCode}, Body: ${response.body}');
    }
  }

  Future<bool> createSafeDepoSlip(int invoiceRef,String username) async {
    await _initializeBaseUrl();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? erpUsername = prefs.getString('erp_username');
    String? erpUserPassword = prefs.getString('erp_userpassword');
    String? safeDepositCode = prefs.getString('safe_deposit_code');

    if (erpUsername == null || erpUserPassword == null || safeDepositCode == null) {
      throw Exception('Отсутствуют необходимые учетные данные EРП или код депозита.');
    }

    String url = '$_baseUrl/api/Invoices/CreateSafeDepoSlip?invoiceRef=$invoiceRef&firmnumber=${_firmNumber ?? ''}&lgusername=$erpUsername&lgpassword=$erpUserPassword&safedepositcode=$safeDepositCode&username=$username';

    final response = await http.post(Uri.parse(url));

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Не удалось создать безопасную квитанцию ​​склада. Код состояния: ${response.statusCode}, Body: ${response.body}');
    }
  }
  Future<bool> changeDriver(int invoiceRef, String driverName) async {
    await _initializeBaseUrl();
    String url =
        '$_baseUrl/api/Invoices/ChangeDriver?invoiceRef=$invoiceRef&drivername=${Uri.encodeComponent(driverName)}&firmnumber=${_firmNumber ?? ''}';

    final response = await http.post(Uri.parse(url));

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(
          'Не удалось сменить водителя. Код состояния: ${response.statusCode}, Body: ${response.body}');
    }
  }

}
