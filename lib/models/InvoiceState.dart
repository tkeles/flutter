import 'package:ngen_delivex/models/InvoiceDto.dart';

class InvoiceState {
  double userDeposit = 0.0;
  double othersCollectedMoney = 0.0;
  double totalAmount = 0.0;
  double deliveredTotalAmount = 0.0;
  int totalInvoiceCount = 0;
  int waitingInvoiceCount = 0;
  int deliveredInvoiceCount = 0;
  int returnedInvoiceCount = 0;

  void reset() {
    userDeposit = 0.0;
    othersCollectedMoney = 0.0;
    totalAmount = 0.0;
    deliveredTotalAmount = 0.0;
    totalInvoiceCount = 0;
    waitingInvoiceCount = 0;
    deliveredInvoiceCount = 0;
    returnedInvoiceCount = 0;
  }

  void updateTotals(List<InvoiceDto> invoices, String status) {
    double sum = invoices.fold(0.0, (acc, invoice) => acc + invoice.totalPrice);
    totalAmount += sum;
    switch (status) {
      case 'WAITING':
        waitingInvoiceCount = invoices.length;
        break;
      case 'DELIVERED':
        deliveredTotalAmount = sum;
        deliveredInvoiceCount = invoices.length;
        break;
      case 'RETURNED':
        returnedInvoiceCount = invoices.length;
        break;
    }
    totalInvoiceCount += invoices.length;
  }
}
