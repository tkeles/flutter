class Reason {
  int? nr;
  String? description;
  String? action;

  Reason({
    this.nr,
    this.description,
    this.action,
  });

  factory Reason.fromJson(Map<String, dynamic> json) {
    return Reason(
      nr: json['nr'] != null ? json['nr'] as int : null,
      description: json['description'] as String?,
      action: json['action'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'NR': nr,
      'Description': description,
      'Action': action,
    };
  }
}
