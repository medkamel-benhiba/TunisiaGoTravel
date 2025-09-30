import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/conversation.dart';

class ConversationHistoryService {
  static const String _conversationsKey = 'conversations';

  static Future<List<Conversation>> getConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final conversationsJson = prefs.getStringList(_conversationsKey) ?? [];
    return conversationsJson
        .map((json) => Conversation.fromJson(jsonDecode(json)))
        .toList();
  }

  static Future<void> saveConversation(Conversation conversation) async {
    final prefs = await SharedPreferences.getInstance();
    final conversationsJson = prefs.getStringList(_conversationsKey) ?? [];

    // Remove existing conversation with same ID, if any
    conversationsJson.removeWhere((json) {
      final Map<String, dynamic> data = jsonDecode(json);
      return data['id'] == conversation.id;
    });

    // Add new conversation
    conversationsJson.add(jsonEncode(conversation.toJson()));
    await prefs.setStringList(_conversationsKey, conversationsJson);
  }

  static Future<void> deleteConversation(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final conversationsJson = prefs.getStringList(_conversationsKey) ?? [];
    conversationsJson.removeWhere((json) {
      final Map<String, dynamic> data = jsonDecode(json);
      return data['id'] == id;
    });
    await prefs.setStringList(_conversationsKey, conversationsJson);
  }
}