import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:tunisiagotravel/providers/global_provider.dart';
import '../models/conversation.dart';
import '../services/conversation_history_service.dart';
import '../theme/color.dart';
import '../widgets/chatBotResponseCard.dart';
import '../widgets/screen_title.dart';
import '../services/api_service.dart';
import '../models/chatbot_response.dart';

class ChatBotScreen extends StatefulWidget {
  final String? initialMessage;
  final Map<String, dynamic> apiResponse;
  final Conversation? existingConversation;

  const ChatBotScreen({
    super.key,
    this.initialMessage,
    required this.apiResponse,
    this.existingConversation,
  });

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  final List<String> greetings = ["bonjour", "salut", "hello", "hi", "hey", "salem", "ahla", "aloha", "bro", "salam"];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late stt.SpeechToText _speech;
  bool _isVoiceRecording = false;
  bool _isLoading = false;
  String? currentConversationId;
  bool hasUnsavedMessages = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

    if (widget.existingConversation != null) {
      currentConversationId = widget.existingConversation!.id;
      _messages.addAll(widget.existingConversation!.messages);
      hasUnsavedMessages = false;
    } else {
      _messages.add({
        "role": "bot",
        "type": "text",
        "content": "Bonjour 👋, je suis votre assistant. Comment puis-je vous aider ?"
      });
      currentConversationId = DateTime.now().millisecondsSinceEpoch.toString();
    }

    if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _addUserMessage(widget.initialMessage!);
      });
    }
  }

  Future<void> _saveCurrentConversation() async {
    if (_messages.length <= 1) return;

    try {
      final conversation = Conversation(
        id: currentConversationId!,
        title: Conversation.generateTitle(_messages),
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
        messages: List.from(_messages),
        messageCount: _messages.where((m) => m['role'] == 'user').length,
      );

      await ConversationHistoryService.saveConversation(conversation);
      setState(() => hasUnsavedMessages = false);
    } catch (e) {
      print('Error saving conversation: $e');
    }
  }

  double _getResponsiveValue(BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return mobile;
    if (width < 1200) return tablet;
    return desktop;
  }

  bool _isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  EdgeInsets _getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
    } else if (width < 1200) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 12);
    }
  }

  double _getMessageMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return width * 0.85;
    } else if (width < 1200) {
      return width * 0.70;
    } else {
      return 600;
    }
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add({
        "role": "user",
        "type": "text",
        "content": text,
      });
      _isLoading = true;
      hasUnsavedMessages = true;
    });

    _scrollToBottom();

    setState(() {
      _messages.add({
        "role": "bot",
        "type": "loading",
        "content": "...",
      });
    });

    final normalizedText = text.trim().toLowerCase();
    final textToSend = greetings.contains(normalizedText) ? "bonjour" : text;

    _sendQuestionToBot(textToSend);
  }

  Future<void> _sendQuestionToBot(String question) async {
    try {
      final response = await ApiService().sendChatbotQuestion(question);

      setState(() {
        _isLoading = false;

        if (_messages.isNotEmpty && _messages.last["type"] == "loading") {
          _messages.removeLast();
        }

        if (response != null) {
          _processChatbotResponse(response);
        } else {
          _messages.add({
            "role": "bot",
            "type": "text",
            "content": "Désolé, je n'ai pas pu traiter votre demande. Veuillez réessayer."
          });
        }
      });

      _scrollToBottom();
      await _saveCurrentConversation();

    } catch (e) {
      setState(() {
        _isLoading = false;

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

  void _processChatbotResponse(Map<String, dynamic> response) {
    final data = response['data'] ?? {};
    final List<ChatbotResponse> responses = [];

    void addResponses(String key, String type) {
      if (data[key] != null && data[key]['data'] != null) {
        final items = data[key]['data'];
        if (items is List && items.isNotEmpty) {
          for (var item in items) {
            responses.add(ChatbotResponse.fromJson({...item, 'type': type}));
          }
        } else if (items is Map && items.isNotEmpty) {
          responses.add(ChatbotResponse.fromJson({...items, 'type': type}));
        }
      }
    }

    addResponses('hotel', 'hotel');
    addResponses('restaurant', 'restaurant');
    addResponses('activity', 'activity');
    addResponses('event', 'event');
    addResponses('circuit', 'circuit');
    addResponses('mussee', 'musee');
    addResponses('partenaire', 'partenaire');
    addResponses('location', 'location');

    setState(() {
      if (responses.isNotEmpty) {
        _messages.add({
          "role": "bot",
          "type": "cards",
          "content": "Voici ce que j'ai trouvé pour vous :",
          "responses": responses,
        });
      } else {
        String finalMessage = response['errormessage']?.toString().isNotEmpty == true
            ? response['errormessage']
            : response['message']?.toString().isNotEmpty == true
            ? response['message']
            : "Je n'ai pas trouvé de résultats correspondant à votre recherche.";

        _messages.add({
          "role": "bot",
          "type": "text",
          "content": finalMessage,
        });
      }
    });
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

      if (_controller.text.isNotEmpty) {
        final voiceText = _controller.text;
        _controller.clear();
        _addUserMessage(voiceText);
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

  Future<bool> _onWillPop() async {
    if (hasUnsavedMessages) {
      await _saveCurrentConversation();
    }
    return true;
  }

  void _showConversationHistory() {
    _scaffoldKey.currentState?.openDrawer();
  }

  Widget _buildMessage(Map<String, dynamic> message) {
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

    final fontSize = _getResponsiveValue(
      context,
      mobile: 14.0,
      tablet: 16.0,
      desktop: 16.0,
    );

    final horizontalPadding = _getResponsiveValue(
      context,
      mobile: 12.0,
      tablet: 16.0,
      desktop: 20.0,
    );

    final verticalPadding = _getResponsiveValue(
      context,
      mobile: 8.0,
      tablet: 12.0,
      desktop: 16.0,
    );

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: _getResponsivePadding(context),
        padding: EdgeInsets.symmetric(
          vertical: verticalPadding,
          horizontal: horizontalPadding,
        ),
        constraints: BoxConstraints(
          maxWidth: _getMessageMaxWidth(context),
          minWidth: 50,
        ),
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
              width: _getResponsiveValue(
                context,
                mobile: 16.0,
                tablet: 20.0,
                desktop: 20.0,
              ),
              height: _getResponsiveValue(
                context,
                mobile: 16.0,
                tablet: 20.0,
                desktop: 20.0,
              ),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isUser ? Colors.white : AppColorstatic.primary,
                ),
              ),
            ),
            SizedBox(width: _getResponsiveValue(
              context,
              mobile: 6.0,
              tablet: 8.0,
              desktop: 8.0,
            )),
            Flexible(
              child: Text(
                "Réflexion en cours...",
                style: TextStyle(
                  color: textColor,
                  fontSize: fontSize,
                  height: 1.4,
                ),
              ),
            ),
          ],
        )
            : Text(
          content,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildCardResponse(Map<String, dynamic> message) {
    final content = message["content"] ?? "";
    final responses = message["responses"] as List<ChatbotResponse>? ?? [];

    final fontSize = _getResponsiveValue(
      context,
      mobile: 14.0,
      tablet: 16.0,
      desktop: 16.0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (content.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: _getResponsivePadding(context),
              padding: EdgeInsets.symmetric(
                vertical: _getResponsiveValue(
                  context,
                  mobile: 8.0,
                  tablet: 12.0,
                  desktop: 16.0,
                ),
                horizontal: _getResponsiveValue(
                  context,
                  mobile: 12.0,
                  tablet: 16.0,
                  desktop: 20.0,
                ),
              ),
              constraints: BoxConstraints(
                maxWidth: _getMessageMaxWidth(context),
              ),
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
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: fontSize,
                  height: 1.4,
                ),
              ),
            ),
          ),
        if (responses.isNotEmpty)
          Container(
            margin: EdgeInsets.only(
              left: _getResponsiveValue(context, mobile: 8.0, tablet: 16.0, desktop: 32.0),
              right: _getResponsiveValue(context, mobile: 8.0, tablet: 16.0, desktop: 32.0),
              top: 8,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return Column(
                    children: responses
                        .map((response) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ChatbotResponseCard(response: response),
                    ))
                        .toList(),
                  );
                } else if (constraints.maxWidth < 1200) {
                  return Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: responses
                        .map((response) => SizedBox(
                      width: (constraints.maxWidth - 8) / 2,
                      child: ChatbotResponseCard(response: response),
                    ))
                        .toList(),
                  );
                } else {
                  return Wrap(
                    spacing: 12.0,
                    runSpacing: 12.0,
                    children: responses
                        .map((response) => SizedBox(
                      width: (constraints.maxWidth - 24) / 3,
                      child: ChatbotResponseCard(response: response),
                    ))
                        .toList(),
                  );
                }
              },
            ),
          ),
      ],
    );
  }

  Widget _buildInputArea() {
    final horizontalMargin = _getResponsiveValue(
      context,
      mobile: 8.0,
      tablet: 16.0,
      desktop: 32.0,
    );

    final inputHeight = _getResponsiveValue(
      context,
      mobile: 50.0,
      tablet: 56.0,
      desktop: 60.0,
    );

    final iconSize = _getResponsiveValue(
      context,
      mobile: 20.0,
      tablet: 24.0,
      desktop: 24.0,
    );

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: horizontalMargin,
        vertical: _isLandscape(context) ? 8.0 : 12.0,
      ),
      height: inputHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(inputHeight / 2),
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
              padding: EdgeInsets.symmetric(
                horizontal: _getResponsiveValue(
                  context,
                  mobile: 16.0,
                  tablet: 20.0,
                  desktop: 24.0,
                ),
                vertical: 8,
              ),
              child: TextField(
                controller: _controller,
                enabled: !_isLoading,
                style: TextStyle(
                  fontSize: _getResponsiveValue(
                    context,
                    mobile: 14.0,
                    tablet: 16.0,
                    desktop: 16.0,
                  ),
                ),
                decoration: InputDecoration(
                  hintText: _isLoading ? "Patientez..." : "Écrivez un message...",
                  hintStyle: TextStyle(
                    fontSize: _getResponsiveValue(
                      context,
                      mobile: 14.0,
                      tablet: 16.0,
                      desktop: 16.0,
                    ),
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: IconButton(
              icon: Icon(
                _isVoiceRecording ? Icons.mic_off : Icons.mic,
                color: Colors.grey[700],
                size: iconSize,
              ),
              onPressed: _isLoading ? null : _toggleVoiceRecording,
            ),
          ),
          if (!_isVoiceRecording)
            Container(
              margin: const EdgeInsets.all(4),
              width: inputHeight - 8,
              height: inputHeight - 8,
              decoration: BoxDecoration(
                color: _isLoading ? Colors.grey : AppColorstatic.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: _isLoading
                    ? SizedBox(
                  width: iconSize - 4,
                  height: iconSize - 4,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : Icon(
                  Icons.send,
                  color: Colors.white,
                  size: iconSize,
                ),
                onPressed: _isLoading ? null : _sendMessage,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConversationDrawer(BuildContext context) { // context needed for MediaQuery, Theme, etc.
    final TextEditingController _searchController = TextEditingController();
    final ValueNotifier<String> _searchQuery = ValueNotifier<String>('');

    // NOTE: If this function is not part of a State class, you will need to pass setState as a callback
    // or use a state management solution (like Provider's notifyListeners or Riverpod's ref.invalidate)
    // for the delete functionality to refresh the list.
    // For simplicity, I'm keeping the original setState() call and assuming it's available or replaceable.

    return Drawer(
      elevation: 16.0,
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 5,
              left: 16,
              right: 16,
              bottom: 12,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColorstatic.primary, AppColorstatic.secondary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'conversation_history'.tr(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (value) => _searchQuery.value = value,
                  decoration: InputDecoration(
                    hintText: 'search_conversations'.tr(),
                    hintStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.white70),
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          // Conversation List
          Expanded(
            child: ValueListenableBuilder<String>(
              valueListenable: _searchQuery,
              builder: (context, searchQuery, _) {
                return FutureBuilder<List<Conversation>>(
                  future: ConversationHistoryService.getConversations(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppColorstatic.primary),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'loading_conversations'.tr(),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'error_loading_conversations'.tr(),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red),
                        ),
                      );
                    }
                    final conversations = snapshot.data ?? [];
                    if (conversations.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'no_conversation'.tr(),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      );
                    }
                    // Filter and sort conversations
                    final filteredConversations = conversations
                        .where((c) => c.title.toLowerCase().contains(searchQuery.toLowerCase()))
                        .toList()
                      ..sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));

                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      itemCount: filteredConversations.length,
                      itemBuilder: (context, index) {
                        final conversation = filteredConversations[index];

                        // --- ENHANCED UI/UX FOR CONVERSATION CARD STARTS HERE ---
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                          child: Material( // Use Material for elevation and InkWell ripple effect
                            elevation: 4,
                            shadowColor: AppColorstatic.primary.withOpacity(0.2), // Themed shadow
                            borderRadius: BorderRadius.circular(16), // More rounded corners
                            clipBehavior: Clip.antiAlias, // Ensures the ripple effect stays within bounds
                            child: InkWell( // Use InkWell for a proper ripple effect on tap
                              onTap: () {
                                Navigator.pop(context);
                                Provider.of<GlobalProvider>(context, listen: false)
                                    .setChatbotConversation(conversation);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  border: Border.all(color: Colors.grey.shade200, width: 0.5),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Conversation Icon
                                    Icon(
                                      Icons.forum_outlined,
                                      color: AppColorstatic.primary,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    // Title and Subtitle
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            conversation.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            // Bolder title
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            DateFormat('dd MMM yyyy, HH:mm', context.locale.toString())
                                                .format(conversation.lastUpdated),
                                            // Muted color for the subtitle
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Delete Button
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                                      tooltip: 'delete_conversation'.tr(),
                                      onPressed: () async {
                                        setState(() {}
                                        );
                                        await ConversationHistoryService.deleteConversation(
                                            conversation.id);
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (hasUnsavedMessages) {
      _saveCurrentConversation();
    }
    _scrollController.dispose();
    _controller.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeAreaPadding = MediaQuery.of(context).padding;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: _buildConversationDrawer(context),
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
              Padding(
                padding: EdgeInsets.only(
                  left: _getResponsiveValue(context, mobile: 10.0, tablet: 16.0, desktop: 32.0),
                  right: _getResponsiveValue(context, mobile: 10.0, tablet: 16.0, desktop: 32.0),
                  top: _isLandscape(context) ? 8.0 : 10.0,
                  bottom: _isLandscape(context) ? 8.0 : 10.0,
                ),
                child: ScreenTitle(
                  title: 'assistant_chatbot'.tr(),
                  icon: Icons.chat_bubble_outline,
                  trailingIcon: Icons.history,
                  onTrailingTap: _showConversationHistory,
                ),
              ),
              SizedBox(height: _isLandscape(context) ? 8.0 : 16.0),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.symmetric(
                        horizontal: _getResponsiveValue(
                          context,
                          mobile: 4.0,
                          tablet: 8.0,
                          desktop: 16.0,
                        ),
                        vertical: 8.0,
                      ),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) => _buildMessage(_messages[index]),
                    );
                  },
                ),
              ),
              _buildInputArea(),
              SizedBox(height: safeAreaPadding.bottom + (_isLandscape(context) ? 4.0 : 8.0)),
            ],
          ),
        ),
      ),
    );
  }
}