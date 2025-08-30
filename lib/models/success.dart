class Success {
  final bool success;

  Success({required this.success});

  factory Success.fromJson(Map<String, dynamic> json) {
    return Success(success: json['success'] ?? false);
  }
}
