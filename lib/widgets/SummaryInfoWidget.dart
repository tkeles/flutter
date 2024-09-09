import 'package:flutter/material.dart';

class SummaryInfoWidget extends StatelessWidget {
  final double userDeposit;
  final double othersCollectedMoney;
  final double totalAmount;
  final double remainingAmount;
  final int totalInvoiceCount;
  final int waitingInvoiceCount;
  final int deliveredInvoiceCount;
  final int returnedInvoiceCount;

  const SummaryInfoWidget({
    required this.userDeposit,
    required this.othersCollectedMoney,
    required this.totalAmount,
    required this.remainingAmount,
    required this.totalInvoiceCount,
    required this.waitingInvoiceCount,
    required this.deliveredInvoiceCount,
    required this.returnedInvoiceCount,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text(
        'Сводные данные',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      children: [
        Container(
          color: Colors.blue[50],
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRow('СУММА ФАКТ:', '$userDeposit', 'ПЕР+ПЕРКОНС:', '$othersCollectedMoney'),
              const SizedBox(height: 8.0),
              _buildRow('ОБЩАЯ СУММА:', '$totalAmount', 'оставшаяся сумма:', '$remainingAmount'),
              const SizedBox(height: 8.0),
              _buildRow('количество :', '$totalInvoiceCount', 'Ожидающие:', '$waitingInvoiceCount'),
              const SizedBox(height: 8.0),
              _buildRow('Доставленные:', '$deliveredInvoiceCount', 'Возвращенные:', '$returnedInvoiceCount'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(String leftLabel, String leftValue, String rightLabel, String rightValue) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              leftLabel,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8.0),
            Text(
              leftValue,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              rightLabel,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8.0),
            Text(
              rightValue,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}
