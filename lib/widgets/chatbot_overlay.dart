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
  bool _speechInitialized = false;
  String _voiceText = '';
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _flutterTts.setSpeechRate(0.7);
  }

  Future<void> _initializeSpeech() async {
    try {
      _speechInitialized = await _speech.initialize(
        onStatus: (status) {
          print('🎤 Speech status: $status, _isListening=$_isListening, _isProcessingVoice=$_isProcessingVoice');
          if (!mounted) return;

          if (status == 'listening' && !_isListening) {
            setState(() => _isListening = true);
          } else if (status == 'notListening' && _isListening) {
            setState(() => _isListening = false);
          }
        },
        onError: (error) {
          print('❌ Speech error: $error');
          if (mounted) {
            setState(() => _isListening = false);
          }
        },
      );
      print('🎤 Speech initialized: $_speechInitialized');
    } catch (e) {
      print('❌ Failed to initialize speech: $e');
      _speechInitialized = false;
    }
  }

  Future<void> _speak(String text) async {
    await _flutterTts.stop();
    await _flutterTts.speak(text);
  }

  Future<void> _startListening() async {
    print('🎤 Starting to listen...');

    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('micPermissionRequired'))),
      );
      return;
    }

    if (!_speechInitialized) {
      await _initializeSpeech();
    }

    if (_speechInitialized && _speech.isAvailable) {
      if (mounted) {
        setState(() {
          _isListening = true;
          _voiceText = '';
          _isNavigating = false;
        });
      }

      await Future.delayed(const Duration(milliseconds: 50));

      await _speech.listen(
        onResult: (val) {
          if (!mounted) return;

          setState(() {
            _voiceText = val.recognizedWords;
            print('🎤 Recognized: $_voiceText');
          });

          if (val.finalResult &&
              _voiceText.isNotEmpty &&
              !_isProcessingVoice &&
              !_isNavigating) {
            print('🎤 Final result, processing voice input');
            Future.microtask(_processVoiceInput);
          }
        },
        listenFor: const Duration(seconds: 12),
        pauseFor: const Duration(seconds: 4),
        cancelOnError: true,
        partialResults: true,
      );
      print('🎤 Listening started, _isListening=$_isListening');
    } else {
      print('❌ Speech not available');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('voiceNotAvailable'))),
        );
      }
    }
  }

  Future<void> _processVoiceInput() async {
    if (_isProcessingVoice || _isNavigating) {
      print('⚠️ Already processing or navigating, skipping');
      return;
    }

    print('🎤 Stopping listening and processing voice input');

    if (_speech.isListening) {
      await _speech.stop();
    }

    if (!mounted) return;

    setState(() => _isListening = false);

    if (_voiceText.isEmpty) {
      print('⚠️ No voice text to process');
      await _speak(tr('didntUnderstand'));
      if (mounted) {
        setState(() {
          _showChatbotOverlay = false;
        });
      }
      return;
    }

    setState(() => _isProcessingVoice = true);

    try {
      print('🎤 Processing: $_voiceText');

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

      final isGreeting = greetings.any((g) =>
          _voiceText.toLowerCase().contains(g.toLowerCase()));

      if (isGreeting) {
        print('👋 Detected greeting');
        final random = Random();
        final response = greetingResponses[random.nextInt(greetingResponses.length)];
        await _speak(response);

        if (mounted) {
          setState(() {
            _isProcessingVoice = false;
            _voiceText = '';
            _showChatbotOverlay = false;
          });
        }
      } else {
        print('🚀 Navigating to chatbot with message: $_voiceText');
        setState(() => _isNavigating = true);

        await _speak(tr('understood'));
        await Future.delayed(const Duration(milliseconds: 300));

        if (mounted) {
          final provider = Provider.of<GlobalProvider>(context, listen: false);
          final messageToSend = _voiceText;

          setState(() {
            _isProcessingVoice = false;
            _voiceText = '';
            _showChatbotOverlay = false;
            _isNavigating = false;
          });

          provider.setChatbotInitialMessage(messageToSend);
          provider.setPage(AppPage.chatbot);
          print('✅ Navigation completed');
        }
      }
    } catch (e) {
      print('❌ Error processing voice: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${tr('processingError')} $e"),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isProcessingVoice = false;
          _voiceText = '';
          _showChatbotOverlay = false;
          _isNavigating = false;
        });
      }
    }
  }

  void _handleChatbotTap() {
    if (!_showChatbotOverlay) {
      print('🤖 Opening chatbot overlay');
      setState(() => _showChatbotOverlay = true);
      _speak(tr('chatbotGreeting'));
    }
  }

  void _handleChatbotOverlayTap() {
    if (_isProcessingVoice || _isNavigating) {
      print('⚠️ Already processing or navigating');
      return;
    }
    if (!_isListening) {
      _startListening();
    }
  }

  void _dismissChatbotOverlay() {
    print('❌ Dismissing overlay');
    if (_speech.isListening) {
      _speech.stop();
    }
    if (mounted) {
      setState(() {
        _isListening = false;
        _showChatbotOverlay = false;
        _voiceText = '';
        _isProcessingVoice = false;
        _isNavigating = false;
      });
    }
  }

  @override
  void dispose() {
    print('🗑️ Disposing ChatbotOverlay');
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
