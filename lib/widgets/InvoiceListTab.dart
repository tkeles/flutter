import 'package:flutter/material.dart';
import 'package:ngen_delivex/models/InvoiceDto.dart';

class InvoiceListTab extends StatelessWidget {
  final Future<List<InvoiceDto>> invoicesFuture;
  final List<int> selectedInvoices; // Birden fazla fatura için liste
  final Function(bool?, int) onCheckboxChanged;

  const InvoiceListTab({
    required this.invoicesFuture,
    required this.selectedInvoices, // Birden fazla fatura için listeyi burada kullanıyoruz
    required this.onCheckboxChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<InvoiceDto>>(
      future: invoicesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('накладной не найдены'));
        } else {
          int rowNumber = 1;
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  const Row(
                    children: [
                      SizedBox(width: 40), // Checkbox space
                      SizedBox(
                        width: 30,
                        child: Text('No', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(
                        width: 100,
                        child: Text('НОМЕР НАКЛАДНОЙ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(
                        width: 300,
                        child: Text('КЛИЕНТ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(
                        width: 100,
                        child: Text('ТИП ОПЛАТА', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(
                        width: 100,
                        child: Text('БРЕНД', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(
                        width: 200,
                        child: Text('ТОРГОВЫЙ АГЕНТ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(
                        width: 100,
                        child: Text('КОЛИЧЕСТВО', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(
                        width: 100,
                        child: Text('ОБЩАЯ СУММА', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(
                        width: 70,
                        child: Text('ДАТА', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const Divider(height: 0.2, thickness: 0.2),
                  ...snapshot.data!.map((invoice) {
                    bool isSelected = selectedInvoices.contains(invoice.logicalRef); // Seçili olup olmadığını kontrol et
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: isSelected, // Seçiliyse checkbox işaretlenecek
                              onChanged: (bool? value) {
                                onCheckboxChanged(value, invoice.logicalRef);
                              },
                            ),
                            SizedBox(
                              width: 30,
                              child: Text('${rowNumber++}', style: TextStyle(fontSize: 12, height: 1.0)),
                            ),
                            SizedBox(
                              width: 100,
                              child: Text(invoice.ficheNo, style: TextStyle(fontSize: 12, height: 1.0)),
                            ),
                            SizedBox(
                              width: 300,
                              child: Text(invoice.customerName, style: TextStyle(fontSize: 12, height: 1.0)),
                            ),
                            SizedBox(
                              width: 100,
                              child: Text(invoice.paymentType, style: TextStyle(fontSize: 12)),
                            ),
                            SizedBox(
                              width: 100,
                              child: Text(invoice.brand, style: TextStyle(fontSize: 12, height: 1.0)),
                            ),
                            SizedBox(
                              width: 200,
                              child: Text(invoice.salesman, style: TextStyle(fontSize: 12, height: 1.0)),
                            ),
                            SizedBox(
                              width: 100,
                              child: Center(
                                child: Text(
                                  '${invoice.quantity}', style: TextStyle(fontSize: 12, height: 1.0),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: Text('${invoice.totalPrice}', style: TextStyle(fontSize: 12, height: 1.0)),
                            ),
                            SizedBox(
                              width: 70,
                              child: Text(invoice.invoiceDate, style: TextStyle(fontSize: 12, height: 1.0)),
                            ),
                          ],
                        ),
                        const Divider(height: 0.2, thickness: 0.2),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
