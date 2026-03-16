import 'package:flutter/material.dart';
import '../models/word_model.dart';
import '../services/database_helper.dart';

class WordProvider with ChangeNotifier {
  List<Word> _allWords = [];
  List<Word> _filteredWords = [];
  String _searchQuery = '';

  List<Word> get words => _filteredWords;

  Future<void> fetchWords() async {
    _allWords = await DatabaseHelper.instance.getAllWords();
    _applyFilter();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredWords = List.from(_allWords);
    } else {
      final query = _searchQuery.toLowerCase();
      _filteredWords = _allWords.where((w) {
        return w.word.toLowerCase().contains(query) ||
            w.translation.toLowerCase().contains(query) ||
            w.type.toLowerCase().contains(query);
      }).toList();
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    _applyFilter();
  }

  // --- CRUD Operations ---
  Future<void> addWord(Word word) async {
    await DatabaseHelper.instance.insert(word);
    await fetchWords();
  }

  Future<void> updateWord(Word word) async {
    await DatabaseHelper.instance.update(word);
    await fetchWords();
  }

  Future<void> deleteWord(int id) async {
    await DatabaseHelper.instance.delete(id);
    _allWords.removeWhere((w) => w.id == id);
    _filteredWords.removeWhere((w) => w.id == id);
    notifyListeners();
  }

  // --- Stats สำหรับ Dashboard ---
  int get totalCount => _allWords.length;
  int get memorizedCount => _allWords.where((w) => w.isMemorized == 1).length;
  int get pendingCount => _allWords.where((w) => w.isMemorized == 0).length;
  int countByType(String type) => _allWords.where((w) => w.type == type).length;

  Word? getRandomPendingWord() {
    final list = _allWords.where((w) => w.isMemorized == 0).toList();
    if (list.isEmpty) return null;
    list.shuffle();
    return list.first;
  }

  // --- ล้างข้อมูลทั้งหมด ---
  Future<void> clearAllWords() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('words');
    _allWords.clear();
    _filteredWords.clear();
    notifyListeners();
  }

  // --- 🔥 โหลดคำศัพท์จริงจากพจนานุกรม 🔥 ---
  Future<void> addWordsFromDictionary() async {
    await clearAllWords(); // ล้างข้อมูลเก่าก่อน

    final List<Map<String, String>> dictionaryData = [
      {
        'word': 'Achievement',
        'translation': 'ความสำเร็จ',
        'type': 'Noun',
        'sentence': 'Winning the prize was a great achievement.',
      },
      {
        'word': 'Believe',
        'translation': 'เชื่อ',
        'type': 'Verb',
        'sentence': 'I believe in you.',
      },
      {
        'word': 'Challenge',
        'translation': 'ความท้าทาย',
        'type': 'Noun',
        'sentence': 'Life is full of challenges.',
      },
      {
        'word': 'Determine',
        'translation': 'มุ่งมั่น',
        'type': 'Verb',
        'sentence': 'Your hard work will determine your success.',
      },
      {
        'word': 'Education',
        'translation': 'การศึกษา',
        'type': 'Noun',
        'sentence': 'Education is the key to the future.',
      },
      {
        'word': 'Frequently',
        'translation': 'บ่อยครั้ง',
        'type': 'Adv',
        'sentence': 'I frequently visit my parents.',
      },
      {
        'word': 'Generous',
        'translation': 'ใจกว้าง',
        'type': 'Adj',
        'sentence': 'She is very generous with her money.',
      },
      {
        'word': 'Healthy',
        'translation': 'สุขภาพดี',
        'type': 'Adj',
        'sentence': 'Eating vegetables makes you healthy.',
      },
      {
        'word': 'Knowledge',
        'translation': 'ความรู้',
        'type': 'Noun',
        'sentence': 'Knowledge is power.',
      },
      {
        'word': 'Together',
        'translation': 'ด้วยกัน',
        'type': 'Adv',
        'sentence': 'Let\'s work together.',
      },
    ];

    for (var data in dictionaryData) {
      await DatabaseHelper.instance.insert(
        Word(
          word: data['word']!,
          translation: data['translation']!,
          type: data['type']!,
          difficulty: 'Medium',
          sentence: data['sentence']!,
          isMemorized: 0,
        ),
      );
    }

    await fetchWords(); // รีเฟรชหน้าจอ
  }
}
