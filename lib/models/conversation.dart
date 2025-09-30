import 'dart:convert';

import 'package:tunisiagotravel/models/chatbot_response.dart';

class Conversation {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime lastUpdated;
  final List<Map<String, dynamic>> messages;
  final int messageCount;

  Conversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.lastUpdated,
    required this.messages,
    required this.messageCount,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final messages = (json['messages'] as List<dynamic>?)
        ?.map((msg) {
      final message = Map<String, dynamic>.from(msg);
      if (message['type'] == 'cards' && message['responses'] != null) {
        // Convert responses to List<ChatbotResponse>
        message['responses'] = (message['responses'] as List<dynamic>)
            .map((resp) => ChatbotResponse.fromJson(Map<String, dynamic>.from(resp)))
            .toList();
      }
      return message;
    })
        .toList() ??
        [];

    return Conversation(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastUpdated: DateTime.parse(json['lastUpdated'] ?? DateTime.now().toIso8601String()),
      messages: messages,
      messageCount: json['messageCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'messages': messages,
      'messageCount': messageCount,
    };
  }


  static String generateTitle(List<Map<String, dynamic>> messages) {
    for (var message in messages) {
      if (message['role'] == 'user' && message['content'] != null) {
        String content = message['content'].toString().trim();
        if (content.isNotEmpty) {
          return content.length > 30 ? '${content.substring(0, 30)}...' : content;
        }
      }
    }
    return 'Nouvelle conversation';
  }

  Conversation copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? lastUpdated,
    List<Map<String, dynamic>>? messages,
    int? messageCount,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      messages: messages ?? this.messages,
      messageCount: messageCount ?? this.messageCount,
    );
  }
}
