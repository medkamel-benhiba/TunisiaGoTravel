import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../providers/global_provider.dart';
import '../theme/color.dart';
import '../widgets/menu_card.dart';
import '../widgets/search_section.dart';
import '../services/api_service.dart';
import 'chatbot_screen.dart';

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _showIntro = false; // controls greeting overlay
  String _voiceText = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
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
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) => setState(() => _voiceText = val.recognizedWords),
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
      try {
        await ApiService().sendVoiceQuestion(_voiceText);
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatBotScreen(initialMessage: _voiceText),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send question: $e')),
        );
      } finally {
        setState(() => _voiceText = '');
      }
    }
  }

  void _handleVoiceButtonTap() {
    if (!_showIntro) {
      setState(() => _showIntro = true);
    }
  }

  void _handleIntroTap() {
    setState(() => _showIntro = false);
    _startListening();
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
        // Floating chatbot button (only if intro not showing)
        if (!_showIntro)
          Positioned(
            right: 16,
            top: size.height / 2 - 40,
            child: GestureDetector(
              onTap: _handleVoiceButtonTap,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset('assets/images/chatbot2.png', width: 80),
                  if (_isListening)
                    const Icon(Icons.mic, color: Colors.redAccent, size: 40),
                ],
              ),
            ),
          ),
        // Intro greeting overlay
        if (_showIntro)
          Positioned(
            top: 1,
            left: 16,
            bottom: size.height / 2,
            child: GestureDetector(
              onTap: _handleIntroTap,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting image
                  Image.asset(
                    'assets/images/chatbot1.png',
                    width: 80,
                  ),
                  const SizedBox(width: 12),
                  // Text on the right with red mic overlay
                  Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 2))
                          ],
                        ),
                        child: const Text(
                          "Bonjour 👋 Je suis votre guide pour \ndécouvrir la Tunisie.\nComment puis-je vous aider ?",
                          style: TextStyle(fontSize: 14, color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Red mic icon on top of text
                      const Positioned(
                        right: 4,
                        bottom: 4,
                        child: Icon(Icons.mic, color: Colors.redAccent, size: 24),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );

  }
}
