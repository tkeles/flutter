import 'package:ngen_delivex/models/InvoiceDto.dart';
import 'package:ngen_delivex/models/Parameter.dart';
import 'package:ngen_delivex/models/reason.dart';
import 'package:ngen_delivex/models/Driver.dart';
import 'package:ngen_delivex/services/ApiService.dart';

class InvoiceService {
  final ApiService apiService;

  InvoiceService(this.apiService); // Constructor expects ApiService instance

  Future<List<InvoiceDto>> getInvoices(String username, String status, String date) {
    return apiService.getInvoices(username, status: status, invoiceDate: date);
  }

  Future<List<Reason>> getReasons() {
    return apiService.getReasons();
  }

  Future<List<Driver>> getDrivers() {
    return apiService.getDrivers();
  }

  // Güncellenmiş metotlar
  Future<bool> updateInvoiceStatus(int invoiceRef, String status) {
    return apiService.updateInvoiceStatus(invoiceRef, status);
  }

  Future<bool> updateInvoiceStatusWithReason(int invoiceRef, String status, String reasonDescription) {
    return apiService.updateInvoiceStatusWithReason(invoiceRef, status, reasonDescription);
  }

  Future<bool> createSafeDepoSlip(int invoiceRef, String username) {
    return apiService.createSafeDepoSlip(invoiceRef, username);
  }

  Future<bool> changeDriver(int invoiceRef, String driverName) {
    return apiService.changeDriver(invoiceRef, driverName);
  }

  Future<Parameter> getParameter(String type) {
    return apiService.getParameter(type);
  }

}
