import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logical_trap_game/utils/i18n.dart';
import 'package:logical_trap_game/utils/theme.dart';
import 'package:logical_trap_game/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const LogicalTrapApp());
}

class LogicalTrapApp extends StatefulWidget {
  const LogicalTrapApp({super.key});

  @override
  State<LogicalTrapApp> createState() => _LogicalTrapAppState();
}

class _LogicalTrapAppState extends State<LogicalTrapApp> {
  final i18n = I18n();

  @override
  void initState() {
    super.initState();
    i18n.addListener(_onLangChange);
  }

  @override
  void dispose() {
    i18n.removeListener(_onLangChange);
    super.dispose();
  }

  void _onLangChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Logical Trap',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: const HomeScreen(),
    );
  }
}
