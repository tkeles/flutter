class Parameter {
  final String type;
  final String value;

  Parameter({required this.type, required this.value});

  // JSON'dan bir Parameter nesnesi oluşturmak için fabrika metodu
  factory Parameter.fromJson(Map<String, dynamic> json) {
    return Parameter(
      type: json['type'],
      value: json['value'],
    );
  }

  // Bir Parameter nesnesini JSON'a dönüştürmek için metot
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'value': value,
    };
  }
}