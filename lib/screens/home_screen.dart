import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tts/flutter_tts.dart'; // ✅ TTS

import '../providers/global_provider.dart';
import '../theme/color.dart';
import '../widgets/menu_card.dart';
import '../widgets/search_section.dart';

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;

  bool _isListening = false;
  bool _showChatbotOverlay = false;
  bool _isProcessingVoice = false;
  String _voiceText = '';

  final List<String> greetings = [
    "bonjour", "salut", "aslema", "hello", "hi", "yo", "salam", "salem", "ahla", "aloha",
    "hey",

  ];

  final List<String> greetingResponses = [
    "Bonjour, comment puis-je vous aider ?",
    "Salut ! Que puis-je faire pour toi ?",
    "Bienvenue, en quoi puis-je vous aider ?",
    "Hello ! Dis-moi ce que tu veux découvrir.",
    "Aslema ! Que cherches-tu aujourd’hui ?",
  ];

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
        const SnackBar(content: Text('Microphone permission is required')),
      );
      return;
    }

    bool available = await _speech.initialize(
      onStatus: (status) => print('Speech status: $status'),
      onError: (error) => print('Speech error: $error'),
    );

    if (available) {
      setState(() {
        _isListening = true;
        _voiceText = '';
      });
      _speech.listen(
        onResult: (val) => setState(() => _voiceText = val.recognizedWords),
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voice recognition not available')),
      );
    }
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);

    if (_voiceText.isNotEmpty) {
      setState(() => _isProcessingVoice = true);

      try {
        print('Processing voice question: $_voiceText');

        // ✅ Vérifie si c'est un greeting
        if (greetings.any((g) => _voiceText.toLowerCase().contains(g))) {
          final random = Random();
          final response =
          greetingResponses[random.nextInt(greetingResponses.length)];

          await _speak(response);

          setState(() {
            _voiceText = '';
            _isProcessingVoice = false;
          });
          return;
        }

        // ✅ Sinon → réponse par défaut + navigation chatbot
        await _speak("J'ai compris, voici le résultat.");

        if (mounted) {
          final provider = Provider.of<GlobalProvider>(context, listen: false);
          provider.setChatbotInitialMessage(_voiceText);
          provider.setPage(AppPage.chatbot);
        }

        setState(() {
          _showChatbotOverlay = false;
          _voiceText = '';
        });
      } catch (e) {
        print('Error processing voice question: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du traitement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isProcessingVoice = false);
      }
    } else {
      // ✅ Aucun texte reconnu
      await _speak("Je n'ai pas compris, pouvez-vous répéter ?");
    }
  }

  void _handleChatbotTap() {
    if (!_showChatbotOverlay) {
      setState(() => _showChatbotOverlay = true);

      _speak(
        "Bonjour ! Je suis votre guide pour découvrir la Tunisie. "
            "Tapez ici pour poser votre question !",
      );
    }
  }

  void _handleChatbotOverlayTap() {
    if (_isProcessingVoice) return;

    if (_isListening) {
      _stopListening();
    } else {
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
    _flutterTts.setSpeechRate(0.7);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      {'title': 'CIRCUITS', 'image': 'assets/images/card/circuit.jpg', 'color': AppColorstatic.primary, 'page': AppPage.circuits},
      {'title': 'GUIDE', 'image': 'assets/images/card/guide.jpg', 'color': AppColorstatic.primary, 'page': AppPage.guide},
      {'title': 'HÔTELS', 'image': 'assets/images/card/hotel.png', 'color': AppColorstatic.secondary, 'page': AppPage.hotels},
      {'title': 'MAISONS D\'HÔTES', 'image': 'assets/images/card/maisondhote.png', 'color': AppColorstatic.secondary, 'page': AppPage.maisonsHotes},
      {'title': 'RESTAURANTS', 'image': 'assets/images/card/resterant.png', 'color': AppColorstatic.primary2, 'page': AppPage.restaurants},
      {'title': 'ÉVÉNEMENT', 'image': 'assets/images/card/event.png', 'color': AppColorstatic.primary2, 'page': AppPage.evenement},
      {'title': 'ACTIVITÉS', 'image': 'assets/images/card/activite.png', 'color': AppColorstatic.secondary, 'page': AppPage.activites},
      {'title': 'TRANSPORTS', 'image': 'assets/images/card/transport.png', 'color': AppColorstatic.secondary},
      {'title': 'CULTURES', 'image': 'assets/images/card/cultures.png', 'color': AppColorstatic.primary, 'page': AppPage.cultures},
      {'title': 'ARTISANAT', 'image': 'assets/images/card/artisanat.png', 'color': AppColorstatic.primary, 'page': AppPage.cultures, 'initialCategory': 'artisanat'},
    ];

    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        ListView(
          children: [
            const SearchSection(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.1,
                ),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  return MenuCard(
                    title: item['title'] as String,
                    imagePath: item['image'] as String,
                    backgroundColor: item['color'] as Color,
                    onTap: item.containsKey('page')
                        ? () {
                      final provider = Provider.of<GlobalProvider>(context, listen: false);
                      provider.setPage(item['page'] as AppPage);
                      if (item['page'] == AppPage.cultures &&
                          item.containsKey('initialCategory')) {
                        provider.setCulturesInitialCategory(item['initialCategory'] as String?);
                      }
                    }
                        : null,
                  );
                },
              ),
            ),
          ],
        ),

        // Floating chatbot button (chatbot2.png)
        if (!_showChatbotOverlay)
          Positioned(
            right: 1,
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
                  width: 80,
                ),
              ),
            ),
          ),

        // Chatbot overlay (chatbot1.png)
        // Chatbot overlay (chatbot1.png)
        if (_showChatbotOverlay)
          Positioned.fill(
            child: GestureDetector(
              onTap: _dismissChatbotOverlay, // ✅ Clicking outside dismisses overlay
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Positioned(
                  top: 100,
                  left: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: () {}, // ✅ Prevents tap from bubbling up to dismiss
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ✅ Only the chatbot image triggers listening
                          GestureDetector(
                            onTap: _handleChatbotOverlayTap, // ✅ Only this triggers listening
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
                                    width: 64,
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
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // ✅ Row for text + close button
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _isProcessingVoice
                                              ? "Traitement en cours...\nVeuillez patienter"
                                              : _isListening
                                              ? "👂 Écoute en cours...\nDites votre question"
                                              : "👋 Bonjour ! Je suis votre guide pour \ndécouvrir la Tunisie.\nTapez ici pour poser votre question !",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                            height: 1.4,
                                            fontWeight: _isListening || _isProcessingVoice
                                                ? FontWeight.w600
                                                : FontWeight.normal,
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
                                        "💬 Reconnu: $_voiceText",
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
