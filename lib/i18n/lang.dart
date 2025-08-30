
import 'files/ar.dart';
import 'files/en.dart';
import 'files/fr.dart';

dynamic langs = {
  "en": en,
  "fr": fr,
  "ar": ar
};

List<Map<String, dynamic>> allLangs = [
  {'name': "English", 'name-en': "English", 'code': "en", 'direction': "ltr"},
  {'name': "Français", 'name-en': "French", 'code': "fr", 'direction': "ltr"},
  {'name': "العربية", 'name-en': "Arabic", 'code': "ar", 'direction': "rtl"},
];
const Map<String, dynamic> lang = {
  'en': {
    'app_title': 'Hello',
    'greeting': 'Hi, how are you?',
    'change_language': 'Change Language',
  },
  'fr': {
    'app_title': 'Bonjour',
    'greeting': 'Salut, comment ça va ?',
    'change_language': 'Changer de langue',
  },
  'ar': {
    'app_title': 'مرحبا',
    'greeting': 'مرحبًا، كيف حالك؟',
    'change_language': 'تغيير اللغة',
  },
  'jo': {
    'app_title': 'مرحبا',
    'greeting': 'مرحبًا، كيف حالك؟',
    'change_language': 'تغيير اللغة',
  },
};
