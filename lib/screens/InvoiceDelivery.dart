// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:ngen_delivex/models/InvoiceDto.dart';
import 'package:ngen_delivex/models/InvoiceState.dart';
import 'package:ngen_delivex/models/Parameter.dart';
import 'package:ngen_delivex/models/reason.dart';
import 'package:ngen_delivex/models/Driver.dart';
import 'package:ngen_delivex/screens/DriverSelectionScreen.dart';
import 'package:ngen_delivex/services/ApiService.dart';
import 'package:ngen_delivex/services/InvoiceService.dart';
import 'package:ngen_delivex/widgets/InvoiceDialog.dart';
import 'package:ngen_delivex/widgets/InvoiceListTab.dart';
import 'package:ngen_delivex/widgets/SummaryInfoWidget.dart';
import 'package:intl/intl.dart';

class InvoiceDeliveryScreen extends StatefulWidget {
  final String username;

  const InvoiceDeliveryScreen({super.key, required this.username});

  @override
  _InvoiceDeliveryScreenState createState() => _InvoiceDeliveryScreenState();
}

class _InvoiceDeliveryScreenState extends State<InvoiceDeliveryScreen> with SingleTickerProviderStateMixin {
  final InvoiceState _invoiceState = InvoiceState();
  final InvoiceService _invoiceService = InvoiceService(ApiService());

  late Future<List<InvoiceDto>> _waitingInvoices;
  late Future<List<InvoiceDto>> _deliveredInvoices;
  late Future<List<InvoiceDto>> _returnedInvoices;
  // Değişiklik Başladı: Tek seçimi listeye çeviriyoruz
  List<int> _selectedInvoices = [];
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  late String _formattedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _formattedDate = DateFormat('dd.MM.yyyy').format(_selectedDate);
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_updateSummaryInfo);
    _initializeInvoices();
  }

  Future<void> _initializeInvoices() async {
    _invoiceState.reset();

    _waitingInvoices = _invoiceService.getInvoices(
      widget.username,
      'WAITING',
      _formattedDate,
    ).then((invoices) {
      setState(() {
        if (invoices.isNotEmpty) {
          _invoiceState.userDeposit = invoices.first.userDeposit;
          _invoiceState.othersCollectedMoney = invoices.first.othersCollectedMoney;
          _invoiceState.totalAmount += invoices.fold(0.0, (sum, invoice) => sum + invoice.totalPrice);
          _invoiceState.waitingInvoiceCount = invoices.length;
          _invoiceState.totalInvoiceCount += _invoiceState.waitingInvoiceCount;
        }
      });
      return invoices;
    });

    _deliveredInvoices = _invoiceService.getInvoices(
      widget.username,
      'DELIVERED',
      _formattedDate,
    ).then((invoices) {
      setState(() {
        if (invoices.isNotEmpty) {
          _invoiceState.userDeposit = invoices.first.userDeposit;
          _invoiceState.othersCollectedMoney = invoices.first.othersCollectedMoney;
          _invoiceState.deliveredTotalAmount += invoices.fold(0.0, (sum, invoice) => sum + invoice.totalPrice);
          _invoiceState.totalAmount += _invoiceState.deliveredTotalAmount;
          _invoiceState.deliveredInvoiceCount = invoices.length;
          _invoiceState.totalInvoiceCount += _invoiceState.deliveredInvoiceCount;
        }
      });
      return invoices;
    });

    _returnedInvoices = _invoiceService.getInvoices(
      widget.username,
      'RETURNED',
      _formattedDate,
    ).then((invoices) {
      setState(() {
        if (invoices.isNotEmpty) {
          _invoiceState.userDeposit = invoices.first.userDeposit;
          _invoiceState.othersCollectedMoney = invoices.first.othersCollectedMoney;
          _invoiceState.totalAmount += invoices.fold(0.0, (sum, invoice) => sum + invoice.totalPrice);
          _invoiceState.returnedInvoiceCount = invoices.length;
          _invoiceState.totalInvoiceCount += _invoiceState.returnedInvoiceCount;
        }
      });
      return invoices;
    });

    await Future.wait([
      _waitingInvoices,
      _deliveredInvoices,
      _returnedInvoices,
    ]);
  }

  void _updateSummaryInfo() {
    setState(() {
      _selectedInvoices.clear(); // Seçimleri temizliyoruz
    });
  }

  // Değişiklik Başladı: Çoklu seçim desteklemesi
  void _onCheckboxChanged(bool? value, int logicalRef) {
    setState(() {
      if (value == true) {
        _selectedInvoices.add(logicalRef);
      } else {
        _selectedInvoices.remove(logicalRef);
      }
    });
  }

  Future<List<InvoiceDto>> _getSelectedInvoiceList() async {
    switch (_tabController.index) {
      case 0:
        return await _waitingInvoices;
      case 1:
        return await _deliveredInvoices;
      case 2:
        return await _returnedInvoices;
      default:
        throw Exception('Неверный индекс вкладки');
    }
  }

  Future<void> _handleMenuAction(String action) async {
    if (_selectedInvoices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Пожалуйста выберите накладные')));
      return;
    }

    // Eğer action 'return' ise ve birden fazla fatura seçildiyse uyarı ver
    if (action == 'return' && _selectedInvoices.length > 1) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Для возврата можно выбрать только одну накладную.')));
      return;
    }

    // Tarih günün tarihinden farklıysa şifre kontrolü yap
    DateTime nowDate = DateTime.now();
    DateTime today = DateTime(nowDate.year, nowDate.month, nowDate.day);
    DateTime selectedDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    if (selectedDate != today) {
      print('Seçilen tarih: $selectedDate');
      bool passwordCorrect = await _showPasswordDialog();
      if (!passwordCorrect) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Неверный пароль')));
        return;
      }
    }

    // Çoklu seçim durumunda onay penceresi gösterme
    if (_selectedInvoices.length > 1) {
      bool confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Подтверждение'),
            content: Text('Вы уверены, что хотите выполнить действие "$action" для ${_selectedInvoices.length} накладных?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Нет'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Да'),
              ),
            ],
          );
        },
      ) ?? false;

      if (!confirm) {
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    int successCount = 0;

    try {
      final invoiceList = await _getSelectedInvoiceList();

      // Filtrele seçilen faturaları mevcut listeye göre
      List<InvoiceDto> selectedInvoicesData = invoiceList.where((invoice) => _selectedInvoices.contains(invoice.logicalRef)).toList();

      // Eğer seçilen faturaların sayısı birden fazlaysa ödeme onayı sadece bir kez sorulacak
      bool paymentReceived = true;

      if (action == 'deliver' && selectedInvoicesData.any((invoice) => invoice.paymentType == 'FAKT')) {
        paymentReceived = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Подтверждение оплаты'),
              content: const Text('Пара алынды mı?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // Hayır butonu
                  },
                  child: const Text('Нет'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // Evet butonu
                  },
                  child: const Text('Да'),
                ),
              ],
            );
          },
        ) ?? false;

        if (!paymentReceived) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Оплата не получена, доставка не выполнена.')));
          return;
        }
      }

      for (var invoice in selectedInvoicesData) {
        try {
          if (action == 'deliver') {
            if (invoice.paymentType == 'FAKT') {
              // Ödeme bir kez soruldu, burayı atlayarak direkt işlemleri yap
              bool updateStatus = await _invoiceService.updateInvoiceStatus(invoice.logicalRef, 'DELIVERED');

              if (updateStatus) {
                bool createSlip = await _invoiceService.createSafeDepoSlip(invoice.logicalRef, widget.username);

                if (createSlip) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Счет доставлен, и платеж получен.')));
                  successCount++;
                } else {
                  await _invoiceService.updateInvoiceStatus(invoice.logicalRef, '');
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Не удалось создать безопасную квитанцию, обновление статуса отменено.')));
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Не удалось обновить статус накладной.')));
              }
            } else {
              // Diğer ödeme tipleri normal şekilde işlem görsün
              bool updateStatus = await _invoiceService.updateInvoiceStatus(invoice.logicalRef, 'DELIVERED');
              if (updateStatus) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Счет доставлен')));
                successCount++;
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Не удалось обновить статус накладной.')));
              }
            }
          } else if (action == 'return') {
            await _handleReturnAction(invoice.logicalRef);
            successCount++;
          } else if (action == 'changeDriver') {
            // Değişiklik Gerektiren Alan: Sürücü değişikliği çoklu seçimde farklı şekilde ele alınmalı
            // Sürücü seçimini tüm faturalar için tek seferde yapmak mantıklı olmayabilir
            // Ancak kullanıcı sürücüyü bir kez seçtiğinde tüm faturalara uygulayacağız

            // İlk faturada sürücü seçimini tetikle
            if (invoice == selectedInvoicesData.first) {
              await _navigateToDriverSelectionScreenForMultipleInvoices(invoiceList, selectedInvoicesData);
              successCount += selectedInvoicesData.length;
              break; // Diğer faturaları zaten değiştiriyoruz
            }
          } else if (action == 'cancelReturn') {
            bool cancelStatus = await _invoiceService.updateInvoiceStatusWithReason(invoice.logicalRef, '', '');
            if (cancelStatus) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Возвратной накладной отменен')));
              successCount++;
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Не удалось отменить возврат накладной.')));
            }
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Действие "$action" выполнено для $successCount накладных.')));
      _initializeInvoices();
      setState(() {
        _selectedInvoices.clear(); // İşlem sonrası seçimleri temizle
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Değişiklik Başladı: Çoklu sürücü değişikliği için yeni metod
  Future<void> _navigateToDriverSelectionScreenForMultipleInvoices(List<InvoiceDto> allInvoices, List<InvoiceDto> selectedInvoicesData) async {
    Driver? selectedDriver = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DriverSelectionScreen(
          onDriverSelected: (Driver driver) {
            Navigator.pop(context, driver);
          },
        ),
      ),
    );

    if (selectedDriver != null) {
      for (var invoice in selectedInvoicesData) {
        try {
          await _invoiceService.changeDriver(invoice.logicalRef, selectedDriver.driverName);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка при изменении водителя для накладной ${invoice.logicalRef}: $e')));
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Водитель заменен: ${selectedDriver.driverName} для ${selectedInvoicesData.length} накладных.'))); // Sürücü değiştirildi
    }
  }

  Future<void> _handleReturnAction(int invoiceRef) async {
    List<Reason> reasons;
    try {
      reasons = await _invoiceService.getReasons();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Возникла ошибка при загрузке причин возврата: $e')),
      );
      return;
    }

    final selectedReason = await InvoiceDialog.showReasonSelectionDialog(context, reasons);

    if (selectedReason != null) {
      try {
        String reasonDescription = selectedReason.description ?? 'Причина не была указана';
        bool updateStatus = await _invoiceService.updateInvoiceStatusWithReason(invoiceRef, 'RETURNED', reasonDescription);
        if (updateStatus) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Счет был возвращен. Причина: ${selectedReason.nr} - $reasonDescription')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Не удалось обновить статус накладной с причиной.')),
          );
        }
        _initializeInvoices();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Когда счет был возвращен, произошла ошибка: $e')),
        );
      }
    }
  }

  Future<bool> _showPasswordDialog() async {
    TextEditingController passwordController = TextEditingController();
    String? adminPassword;
    Parameter parameter;

    try {
      parameter = await _invoiceService.getParameter('AdminPassword');
      adminPassword = parameter.value;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка при получении пароля: $e')));
      return false;
    }

    bool isPasswordCorrect = false;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Введите пароль'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Пароль'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                if (passwordController.text == adminPassword) {
                  isPasswordCorrect = true;
                }
                Navigator.of(context).pop();
              },
              child: const Text('ОК'),
            ),
          ],
        );
      },
    );

    return isPasswordCorrect;
  }


  Future<void> _handleCancelReturn() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Отменить возврат'),
          content: const Text('Возвратной накладной будет отменен. Вы уверены?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Нет'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Да'),
            ),
          ],
        );
      },
    );
    if (confirm == true) {
      await _handleMenuAction('cancelReturn');
    }
  }

  void _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _formattedDate = DateFormat('dd.MM.yyyy').format(_selectedDate);
        _invoiceState.reset();
      });
      _initializeInvoices();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_updateSummaryInfo);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ОБЩАЯ РЕЕСТР ДЛЯ ${widget.username}"),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                color: Colors.blue[50],
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'ВЫБЕРИТЕ ДАТУ:',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      _formattedDate,
                      style: const TextStyle(fontSize: 13),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _selectDate,
                    ),
                  ],
                ),
              ),
              SummaryInfoWidget(
                userDeposit: _invoiceState.userDeposit,
                othersCollectedMoney: _invoiceState.othersCollectedMoney,
                totalAmount: _invoiceState.totalAmount,
                remainingAmount: _invoiceState.totalAmount - _invoiceState.deliveredTotalAmount,
                totalInvoiceCount: _invoiceState.totalInvoiceCount,
                waitingInvoiceCount: _invoiceState.waitingInvoiceCount,
                deliveredInvoiceCount: _invoiceState.deliveredInvoiceCount,
                returnedInvoiceCount: _invoiceState.returnedInvoiceCount,
              ),
              const SizedBox(height: 10.0),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: const [
                  Tab(text: "ОЖИДАЮЩЫЙ"),
                  Tab(text: "ДОСТАВЛЕННЫЙ"),
                  Tab(text: "ВОЗВРАТ"),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    InvoiceListTab(
                      invoicesFuture: _waitingInvoices,
                      selectedInvoices: _selectedInvoices, // Değişiklik: Çoklu seçim
                      onCheckboxChanged: _onCheckboxChanged,
                    ),
                    InvoiceListTab(
                      invoicesFuture: _deliveredInvoices,
                      selectedInvoices: _selectedInvoices, // Değişiklik: Çoklu seçim
                      onCheckboxChanged: _onCheckboxChanged,
                    ),
                    InvoiceListTab(
                      invoicesFuture: _returnedInvoices,
                      selectedInvoices: _selectedInvoices, // Değişiklik: Çoklu seçim
                      onCheckboxChanged: _onCheckboxChanged,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _initializeInvoices,
            child: const Icon(Icons.refresh),
            tooltip: 'Обновить',
          ),
          const SizedBox(height: 16.0),
          if (_selectedInvoices.isNotEmpty)
            FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Wrap(
                      children: <Widget>[
                        ListTile(
                          leading: const Icon(Icons.local_shipping),
                          title: const Text('Доставить клиенту'),
                          onTap: () {
                            Navigator.pop(context);
                            _handleMenuAction('deliver');
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.undo),
                          title: const Text('возвращать'),
                          onTap: () {
                            Navigator.pop(context);
                            _handleMenuAction('return');
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: const Text('Сменить драйвер'),
                          onTap: () {
                            Navigator.pop(context);
                            _handleMenuAction('changeDriver');
                          },
                        ),
                        if (_tabController.index == 2)
                          ListTile(
                            leading: const Icon(Icons.cancel),
                            title: const Text('Отменить возврат'),
                            onTap: () {
                              Navigator.pop(context);
                              _handleMenuAction('cancelReturn');
                            },
                          ),
                      ],
                    );
                  },
                );
              },
              tooltip: 'Опции',
              child: const Icon(Icons.menu),
            ),
        ],
      ),
    );
  }
}
