class ChatbotResponse {
  final String type;
  final String id;
  final String title;
  final String cover;
  final String? description;
  final String? slug;

  ChatbotResponse({
    required this.type,
    required this.id,
    required this.title,
    required this.cover,
    this.description,
    this.slug,
  });

  factory ChatbotResponse.fromJson(Map<String, dynamic> json) {
    return ChatbotResponse(
      type: json['type'] ?? '',
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? json['name'] ?? '',
      cover: json['cover'] ?? json['image'] ?? '',
      description: json['description'],
      slug: json['slug'],    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'id': id,
      'title': title,
      'cover': cover,
      'description': description,
      'slug': slug,
    };
  }

  // Helper method to get navigation page based on type
  String getNavigationRoute() {
    switch (type.toLowerCase()) {
      case 'hotel':
        return '/hotel-details';
      case 'restaurant':
        return '/restaurant-details';
      case 'activity':
        return '/activity-details';
      case 'event':
        return '/event-details';
      case 'circuit':
        return '/circuit-details';
      case 'culture':
        return '/culture-details';
      default:
        return '/details';
    }
  }
}