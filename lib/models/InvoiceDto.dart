// ignore: file_names
class InvoiceDto {
  final int no;
  final int logicalRef;
  final String invoiceDate;
  final String ficheNo;
  final String paymentType;
  final String customerName;
  final String brand;
  final String salesman;
  final int quantity;
  final double totalPrice;
  final double userDeposit;
  final double othersCollectedMoney;

  InvoiceDto({
    required this.no,
    required this.logicalRef,
    required this.invoiceDate,
    required this.ficheNo,
    required this.paymentType,
    required this.customerName,
    required this.brand,
    required this.salesman,
    required this.quantity,
    required this.totalPrice,
    required this.userDeposit,
    required this.othersCollectedMoney ,
  });

  factory InvoiceDto.fromJson(Map<String, dynamic> json) {
    return InvoiceDto(
      no: json['no'],
      logicalRef: json['logicalRef'],
      invoiceDate: json['invoiceDate'],
      ficheNo: json['ficheNo'],
      paymentType: json['paymentType'],
      customerName: json['customerName'],
      brand: json['brand'],
      salesman: json['salesman'],
      quantity: json['quantity'],
      totalPrice: json['totalPrice'].toDouble(),
      userDeposit: json['userDeposit'].toDouble(),
      othersCollectedMoney : json['othersCollectedMoney'].toDouble(),
    );
  }
}
