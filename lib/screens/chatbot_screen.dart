import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../theme/color.dart';
import '../widgets/screen_title.dart';
import '../services/api_service.dart';

class ChatBotScreen extends StatefulWidget {
  final String? initialMessage;
  const ChatBotScreen({super.key, this.initialMessage});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];

  late stt.SpeechToText _speech;
  bool _isVoiceRecording = false;
  bool _isLoading = false; // Add loading state

  @override
  void initState() {
    super.initState();

    _speech = stt.SpeechToText();

    _messages.add({
      "role": "bot",
      "text": "Bonjour 👋, je suis votre assistant. Comment puis-je vous aider ?"
    });

    if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      _addUserMessage(widget.initialMessage!);
    }
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add({"role": "user", "text": text});
      _isLoading = true; // Show loading when user sends message
    });

    // Auto-scroll
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    // Add loading message
    setState(() {
      _messages.add({"role": "bot", "text": "..."});
    });

    // Send to API and get response
    _sendQuestionToBot(text);
  }

  Future<void> _sendQuestionToBot(String question) async {
    try {
      final response = await ApiService().sendVoiceQuestion(question);

      setState(() {
        _isLoading = false;
        // Remove the loading message (last message)
        if (_messages.isNotEmpty && _messages.last["text"] == "...") {
          _messages.removeLast();
        }

        // Add the actual response
        if (response != null) {
          // Handle different response formats
          String botResponse = '';

          // Check if response is a Map with specific fields
          if (response is Map<String, dynamic>) {
            // Try to get the response text from common field names
            botResponse = response['response'] ??
                response['answer'] ??
                response['message'] ??
                response['text'] ??
                response.toString();
          } else if (response is String) {
            botResponse = response as String;
          } else {
            botResponse = response.toString();
          }

          _messages.add({
            "role": "bot",
            "text": botResponse.isNotEmpty ? botResponse : "Je n'ai pas pu traiter votre demande."
          });
        } else {
          _messages.add({
            "role": "bot",
            "text": "Désolé, je n'ai pas pu traiter votre demande. Veuillez réessayer."
          });
        }
      });

      // Auto-scroll to show new message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
        // Remove the loading message
        if (_messages.isNotEmpty && _messages.last["text"] == "...") {
          _messages.removeLast();
        }

        _messages.add({
          "role": "bot",
          "text": "Une erreur s'est produite. Veuillez réessayer."
        });
      });

      print('Error in _sendQuestionToBot: $e');
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return; // Prevent sending while loading
    _controller.clear();
    _addUserMessage(text);
  }

  /// Toggle voice recording using speech_to_text
  Future<void> _toggleVoiceRecording() async {
    if (_isLoading) return; // Prevent voice recording while loading

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
      if (_controller.text.isNotEmpty) {
        _addUserMessage(_controller.text);
        _controller.clear();
      }
    }
  }

  Widget _buildMessage(Map<String, String> message) {
    final isUser = message["role"] == "user";
    final color = isUser ? AppColorstatic.primary : Colors.grey[200];
    final textColor = isUser ? Colors.white : Colors.black87;
    final text = message["text"] ?? "";

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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
        ),
        child: text == "..."
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
          text,
          style: TextStyle(color: textColor, fontSize: 16, height: 1.4),
        ),
      ),
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
          gradient: LinearGradient(colors: [Colors.white, Colors.grey[100]!], begin: Alignment.topCenter, end: Alignment.bottomCenter),
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
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _controller,
                        enabled: !_isLoading, // Disable when loading
                        decoration: InputDecoration(
                            hintText: _isLoading ? "Patientez..." : "Écrivez un message...",
                            border: InputBorder.none
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(_isVoiceRecording ? Icons.mic_off : Icons.mic, color: Colors.grey[700]),
                    onPressed: _isLoading ? null : _toggleVoiceRecording, // Disable when loading
                  ),
                  if (!_isVoiceRecording)
                    Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: _isLoading ? Colors.grey : AppColorstatic.primary,
                          shape: BoxShape.circle
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
                        onPressed: _isLoading ? null : _sendMessage, // Disable when loading
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