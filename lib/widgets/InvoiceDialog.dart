// lib/widgets/InvoiceDialog.dart

import 'package:flutter/material.dart';
import 'package:ngen_delivex/models/reason.dart';

class InvoiceDialog {
  static Future<Reason?> showReasonSelectionDialog(BuildContext context, List<Reason> reasons) {
    return showDialog<Reason>(
      context: context,
      builder: (BuildContext context) {
        Reason? tempSelectedReason;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Выберите причину возврата'),
              content: SingleChildScrollView(
                child: Column(
                  children: reasons.map((reason) {
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: RadioListTile<Reason>(
                        title: Text('${reason.nr}: ${reason.description}'),
                        value: reason,
                        groupValue: tempSelectedReason,
                        onChanged: (Reason? value) {
                          setState(() {
                            tempSelectedReason = value;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading, // Radio button'ı sola yerleştirir
                      ),
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Dialogu kapat
                  },
                  child: const Text('отмена'),
                ),
                ElevatedButton(
                  onPressed: tempSelectedReason != null
                      ? () {
                    Navigator.of(context).pop(tempSelectedReason); // Seçilen sebebi geri döndür
                  }
                      : null, // Eğer hiçbir sebep seçilmediyse buton inaktif olsun
                  child: const Text('Выбирать'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
