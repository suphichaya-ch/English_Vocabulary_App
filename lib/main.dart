import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/word_provider.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // สร้าง WordProvider
  final wordProvider = WordProvider();

  // โหลดข้อมูลจากฐานข้อมูล
  await wordProvider.fetchWords();

  // ✅ โหลดคำศัพท์จริงจากไฟล์ JSON หากฐานข้อมูลว่าง
  if (wordProvider.totalCount == 0) {
    await wordProvider.addWordsFromDictionary();
  }

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider.value(value: wordProvider)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'English Vocab App',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const DashboardScreen(),
    );
  }
}
