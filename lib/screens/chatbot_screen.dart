import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../theme/color.dart';
import '../widgets/chatBotResponseCard.dart';
import '../widgets/screen_title.dart';
import '../services/api_service.dart';
import '../models/chatbot_response.dart';

class ChatBotScreen extends StatefulWidget {
  final String? initialMessage;
  final Map<String, dynamic> apiResponse;

  const ChatBotScreen({
    super.key,
    this.initialMessage,
    required this.apiResponse,
  });

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];

  late stt.SpeechToText _speech;
  bool _isVoiceRecording = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

    // Add welcome message
    _messages.add({
      "role": "bot",
      "type": "text",
      "content": "Bonjour 👋, je suis votre assistant. Comment puis-je vous aider ?"
    });

    // Process initial message if provided
    if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _addUserMessage(widget.initialMessage!);
      });
    }
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add({
        "role": "user",
        "type": "text",
        "content": text
      });
      _isLoading = true;
    });

    _scrollToBottom();

    // Add loading message
    setState(() {
      _messages.add({
        "role": "bot",
        "type": "loading",
        "content": "..."
      });
    });

    // Send to API
    _sendQuestionToBot(text);
  }

  Future<void> _sendQuestionToBot(String question) async {
    try {
      // Call the chatbot API
      final response = await ApiService().sendChatbotQuestion(question);

      setState(() {
        _isLoading = false;

        // Remove loading message
        if (_messages.isNotEmpty && _messages.last["type"] == "loading") {
          _messages.removeLast();
        }

        if (response != null && response['data'] != null) {
          _processChatbotResponse(response['data']);
        } else {
          _messages.add({
            "role": "bot",
            "type": "text",
            "content": "Désolé, je n'ai pas pu traiter votre demande. Veuillez réessayer."
          });
        }
      });

      _scrollToBottom();

    } catch (e) {
      setState(() {
        _isLoading = false;

        // Remove loading message
        if (_messages.isNotEmpty && _messages.last["type"] == "loading") {
          _messages.removeLast();
        }

        _messages.add({
          "role": "bot",
          "type": "text",
          "content": "Une erreur s'est produite. Veuillez réessayer."
        });
      });

      print('Error in _sendQuestionToBot: $e');
    }
  }

  void _processChatbotResponse(Map<String, dynamic> data) {
    List<ChatbotResponse> responses = [];

    // Process different types of responses
    if (data['hotel'] != null && data['hotel']['data'] != null) {
      final hotels = data['hotel']['data'] as List;
      for (var hotel in hotels) {
        responses.add(ChatbotResponse.fromJson({
          ...hotel,
          'type': 'hotel'
        }));
      }
    }

    if (data['restaurant'] != null && data['restaurant']['data'] != null) {
      final restaurants = data['restaurant']['data'] as List;
      for (var restaurant in restaurants) {
        responses.add(ChatbotResponse.fromJson({
          ...restaurant,
          'type': 'restaurant'
        }));
      }
    }

    if (data['activity'] != null && data['activity']['data'] != null) {
      final activities = data['activity']['data'] as List;
      for (var activity in activities) {
        responses.add(ChatbotResponse.fromJson({
          ...activity,
          'type': 'activity'
        }));
      }
    }

    if (data['event'] != null && data['event']['data'] != null) {
      final events = data['event']['data'] as List;
      for (var event in events) {
        responses.add(ChatbotResponse.fromJson({
          ...event,
          'type': 'event'
        }));
      }
    }

    if (data['circuit'] != null && data['circuit']['data'] != null) {
      final circuits = data['circuit']['data'];
      if (circuits is List) {
        for (var circuit in circuits) {
          responses.add(ChatbotResponse.fromJson({
            ...circuit,
            'type': 'circuit'
          }));
        }
      } else if (circuits is Map) {
        responses.add(ChatbotResponse.fromJson({
          ...circuits,
          'type': 'circuit'
        }));
      }
    }

    // Add the responses as cards
    if (responses.isNotEmpty) {
      setState(() {
        _messages.add({
          "role": "bot",
          "type": "cards",
          "content": "Voici ce que j'ai trouvé pour vous :",
          "responses": responses
        });
      });
    } else {
      // No cards found, add text response
      setState(() {
        _messages.add({
          "role": "bot",
          "type": "text",
          "content": "Je n'ai pas trouvé de résultats correspondant à votre recherche. Pouvez-vous reformuler votre question ?"
        });
      });
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;
    _controller.clear();
    _addUserMessage(text);
  }

  Future<void> _toggleVoiceRecording() async {
    if (_isLoading) return;

    if (!_isVoiceRecording) {
      bool available = await _speech.initialize(
        onStatus: (status) => print('Speech status: $status'),
        onError: (err) => print('Speech error: $err'),
      );

      if (available) {
        setState(() => _isVoiceRecording = true);
        _speech.listen(
          onResult: (val) {
            if (val.hasConfidenceRating && val.confidence > 0) {
              _controller.text = val.recognizedWords;
            }
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Voice recognition not available')),
        );
      }
    } else {
      _speech.stop();
      setState(() => _isVoiceRecording = false);

      // AUTO-SEND: Automatically send the voice message without manual confirmation
      if (_controller.text.isNotEmpty) {
        final voiceText = _controller.text;
        _controller.clear();
        _addUserMessage(voiceText); // This will automatically send the message
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    final isUser = message["role"] == "user";
    final messageType = message["type"] ?? "text";

    if (messageType == "cards") {
      return _buildCardResponse(message);
    }

    return _buildTextMessage(message);
  }

  Widget _buildTextMessage(Map<String, dynamic> message) {
    final isUser = message["role"] == "user";
    final color = isUser ? AppColorstatic.primary : Colors.grey[200];
    final textColor = isUser ? Colors.white : Colors.black87;
    final content = message["content"] ?? "";
    final messageType = message["type"] ?? "text";

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: messageType == "loading"
            ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isUser ? Colors.white : AppColorstatic.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "Réflexion en cours...",
              style: TextStyle(color: textColor, fontSize: 16, height: 1.4),
            ),
          ],
        )
            : Text(
          content,
          style: TextStyle(color: textColor, fontSize: 16, height: 1.4),
        ),
      ),
    );
  }

  Widget _buildCardResponse(Map<String, dynamic> message) {
    final content = message["content"] ?? "";
    final responses = message["responses"] as List<ChatbotResponse>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text message
        if (content.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                content,
                style: const TextStyle(color: Colors.black87, fontSize: 16, height: 1.4),
              ),
            ),
          ),
        // Cards
        if (responses.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(left: 8, right: 8, top: 8),
            child: Column(
              children: responses.map((response) =>
                  ChatbotResponseCard(response: response)
              ).toList(),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey[100]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: ScreenTitle(title: 'Assistant Chatbot', icon: Icons.chat_bubble_outline),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (context, index) => _buildMessage(_messages[index]),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _controller,
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          hintText: _isLoading ? "Patientez..." : "Écrivez un message...",
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isVoiceRecording ? Icons.mic_off : Icons.mic,
                      color: Colors.grey[700],
                    ),
                    onPressed: _isLoading ? null : _toggleVoiceRecording,
                  ),
                  if (!_isVoiceRecording)
                    Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _isLoading ? Colors.grey : AppColorstatic.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: _isLoading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : const Icon(Icons.send, color: Colors.white),
                        onPressed: _isLoading ? null : _sendMessage,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}