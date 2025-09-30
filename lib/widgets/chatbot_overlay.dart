import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/global_provider.dart';
import '../theme/color.dart';

class ChatbotOverlay extends StatefulWidget {
  const ChatbotOverlay({super.key});

  @override
  State<ChatbotOverlay> createState() => _ChatbotOverlayState();
}

class _ChatbotOverlayState extends State<ChatbotOverlay> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;

  bool _isListening = false;
  bool _showChatbotOverlay = false;
  bool _isProcessingVoice = false;
  String _voiceText = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _flutterTts.setSpeechRate(0.7);
  }

  Future<void> _speak(String text) async {
    await _flutterTts.stop();
    await _flutterTts.speak(text);
  }

  Future<void> _startListening() async {
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('micPermissionRequired'))),
      );
      return;
    }

    bool available = await _speech.initialize(
      onStatus: (status) {
        print('Speech status: $status');
        if (status == 'done' || status == 'notListening') {
          _stopListening();
        }
      },
      onError: (error) {
        print('Speech error: $error');
      },
    );

    if (available) {
      setState(() {
        _isListening = true;
        _voiceText = '';
      });
      _speech.listen(
        onResult: (val) => setState(() => _voiceText = val.recognizedWords),
        listenFor: const Duration(seconds: 13),
        pauseFor: const Duration(seconds: 5),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('voiceNotAvailable'))),
      );
    }
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);

    if (_voiceText.isNotEmpty) {
      setState(() => _isProcessingVoice = true);

      try {
        final greetings = [
          tr('chatbot.greetingWord1'),
          tr('chatbot.greetingWord2'),
          tr('chatbot.greetingWord3'),
          tr('chatbot.greetingWord4'),
        ];

        final greetingResponses = [
          tr('chatbot.greeting1'),
          tr('chatbot.greeting2'),
          tr('chatbot.greeting3'),
          tr('chatbot.greeting4'),
        ];

        if (greetings.any((g) => _voiceText.toLowerCase().contains(g.toLowerCase()))) {
          final random = Random();
          final response = greetingResponses[random.nextInt(greetingResponses.length)];
          await _speak(response);
        } else {
          await _speak(tr('understood'));
          if (mounted) {
            final provider = Provider.of<GlobalProvider>(context, listen: false);
            provider.setChatbotInitialMessage(_voiceText);
            provider.setPage(AppPage.chatbot);
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${tr('processingError')} $e"),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isProcessingVoice = false;
          _voiceText = '';
          _showChatbotOverlay = false;
        });
      }
    } else {
      await _speak(tr('didntUnderstand'));
    }
  }

  void _handleChatbotTap() {
    if (!_showChatbotOverlay) {
      setState(() => _showChatbotOverlay = true);
      _speak(tr('chatbotGreeting'));
    }
  }

  void _handleChatbotOverlayTap() {
    if (_isProcessingVoice) return;
    if (!_isListening) {
      _startListening();
    }
  }

  void _dismissChatbotOverlay() {
    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
    }
    setState(() {
      _showChatbotOverlay = false;
      _voiceText = '';
    });
  }

  @override
  void dispose() {
    _speech.stop();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        if (!_showChatbotOverlay)
          Positioned(
            right: 2,
            top: size.height / 2 - 40,
            child: GestureDetector(
              onTap: _handleChatbotTap,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/chatbot2.png',
                  width: 70,
                ),
              ),
            ),
          ),
        // Chatbot overlay
        if (_showChatbotOverlay)
          Positioned.fill(
            child: GestureDetector(
              onTap: _dismissChatbotOverlay,
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Stack(
                  children: [
                    Positioned(
                      top: 80,
                      left: 16,
                      right: 16,
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: _handleChatbotOverlayTap,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(40),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      child: Image.asset(
                                        'assets/images/chatbot1.png',
                                        width: 54,
                                      ),
                                    ),
                                    if (_isListening)
                                      Positioned(
                                        bottom: -5,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.mic,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    if (_isProcessingVoice)
                                      Positioned(
                                        bottom: -5,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: AppColorstatic.primary,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _isProcessingVoice
                                                ? tr('chatbot.processing')
                                                : _isListening
                                                ? tr('chatbot.listening')
                                                : tr('chatbot.welcome'),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: _dismissChatbotOverlay,
                                          child: const Icon(
                                            Icons.close,
                                            size: 20,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (_voiceText.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE3F2FD),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: const Color(0xFF90CAF9)),
                                        ),
                                        child: Text(
                                          tr('chatbot.recognized', args: [_voiceText]),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue[700],
                                            fontStyle: FontStyle.italic,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}