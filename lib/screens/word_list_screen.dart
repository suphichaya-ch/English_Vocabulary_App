import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/word_provider.dart';
import 'word_detail_screen.dart';

class WordListScreen extends StatelessWidget {
  const WordListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WordProvider>();
    final words = provider.words;

    return Scaffold(
      backgroundColor: Colors.grey[50], // พื้นหลังสีเทาอ่อนให้ดูแพง
      appBar: AppBar(
        title: const Text(
          'คลังคำศัพท์ของคุณ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // 🔍 ส่วนค้นหาที่ดูดีขึ้น
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              onChanged: (value) => provider.setSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'ค้นหาคำศัพท์หรือคำแปล...',
                prefixIcon: const Icon(Icons.search, color: Colors.blue),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // 📜 รายการคำศัพท์แบบการ์ดที่เลื่อนไหล
          Expanded(
            child: words.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: words.length,
                    itemBuilder: (context, index) {
                      final word = words[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Dismissible(
                          key: Key(word.id.toString()),
                          direction: DismissDirection.endToStart,
                          background: _buildDeleteBackground(),
                          confirmDismiss: (direction) =>
                              _showConfirmDelete(context, word.word),
                          onDismissed: (_) => provider.deleteWord(word.id!),
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: word.isMemorized == 1
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.blue.withOpacity(0.1),
                                child: Icon(
                                  word.isMemorized == 1
                                      ? Icons.check
                                      : Icons.book,
                                  color: word.isMemorized == 1
                                      ? Colors.green
                                      : Colors.blue,
                                ),
                              ),
                              title: Text(
                                word.word,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                word.translation,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 14,
                                color: Colors.grey,
                              ),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => WordDetailScreen(word: word),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // พื้นหลังเวลาปัดลบ
  Widget _buildDeleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Icon(Icons.delete_sweep, color: Colors.white, size: 30),
    );
  }

  // หน้าจอเมื่อไม่พบข้อมูล
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'ไม่พบคำศัพท์ที่คุณค้นหา',
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Dialog ยืนยันการลบ
  Future<bool> _showConfirmDelete(BuildContext context, String word) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Text('ลบคำศัพท์?'),
            content: Text('คุณแน่ใจนะว่าต้องการลบ "$word" ออกจากรายการ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('ยกเลิก'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('ลบออก', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }
}
