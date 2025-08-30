class Guide {
  final String id;
  final String name;
  final String lastName;
  final String address;
  final String description;
  final String email;
  final String phone;
  final String status;
  final String photo;

  Guide({
    required this.id,
    required this.name,
    required this.lastName,
    required this.address,
    required this.description,
    required this.email,
    required this.phone,
    required this.status,
    required this.photo,
  });

  factory Guide.fromJson(Map<String, dynamic> json) {
    return Guide(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      lastName: json['last_name'] ?? '',
      address: json['address'] ?? '',
      description: json['description'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      status: json['status'] ?? '',
      photo: json['photo'] ?? '',
    );
  }
}
