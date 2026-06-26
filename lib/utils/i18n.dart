import 'package:flutter/material.dart';

/// Translation service for bilingual support
class I18n extends ChangeNotifier {
  static final I18n _instance = I18n._();
  factory I18n() => _instance;
  I18n._();

  String _lang = 'en';

  String get lang => _lang;

  void setLang(String lang) {
    _lang = lang;
    notifyListeners();
  }

  void toggle() {
    _lang = _lang == 'en' ? 'hi' : 'en';
    notifyListeners();
  }

  bool get isHindi => _lang == 'hi';
}

/// Extension to get localized text
extension BilingualX on Map<String, String> {
  String get localized => I18n().lang == 'hi' && containsKey('hi')
      ? this['hi']!
      : this['en']!;
}

/// App-level strings
class AppStrings {
  static const Map<String, Map<String, String>> _strings = {
    'appName': {'en': 'Logical Trap', 'hi': 'लॉजिकल ट्रैप'},
    'play': {'en': 'Play', 'hi': 'खेलें'},
    'next': {'en': 'Next', 'hi': 'अगला'},
    'hint': {'en': 'Hint', 'hi': 'संकेत'},
    'score': {'en': 'Score', 'hi': 'स्कोर'},
    'lives': {'en': 'Lives', 'hi': 'जीवन'},
    'level': {'en': 'Level', 'hi': 'स्तर'},
    'correct': {'en': 'Correct! 🎉', 'hi': 'सही! 🎉'},
    'wrong': {'en': 'Wrong! Try Again', 'hi': 'गलत! फिर से प्रयास करें'},
    'gameOver': {'en': 'Game Over', 'hi': 'खेल समाप्त'},
    'newGame': {'en': 'New Game', 'hi': 'नया खेल'},
    'settings': {'en': 'Settings', 'hi': 'सेटिंग्स'},
    'language': {'en': 'Language', 'hi': 'भाषा'},
    'noHint': {'en': 'No hints left', 'hi': 'कोई संकेत नहीं बचा'},
    'hintReveal': {'en': '💡 Hint:', 'hi': '💡 संकेत:'},
    'completed': {'en': 'Completed', 'hi': 'पूर्ण'},
    'totalPuzzles': {'en': 'Total Puzzles', 'hi': 'कुल पहेलियाँ'},
    'youWin': {'en': 'You Win! 🏆', 'hi': 'आप जीते! 🏆'},
    'allDone': {'en': 'All puzzles solved!', 'hi': 'सभी पहेलियाँ हल!'},
    'typeAnswer': {'en': 'Type your answer...', 'hi': 'अपना उत्तर लिखें...'},
  };

  static String get(String key) {
    final lang = I18n().lang;
    return _strings[key]?[lang] ?? _strings[key]?['en'] ?? key;
  }
}
