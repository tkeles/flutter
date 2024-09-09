class Driver {
  final String driverName;

  Driver({required this.driverName});

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      driverName: json['driverName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'driverName': driverName,
    };
  }
}