import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/word_model.dart';
import '../providers/word_provider.dart';
import 'word_form_screen.dart';

class WordDetailScreen extends StatelessWidget {
  final Word word;

  const WordDetailScreen({Key? key, required this.word}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary Detail'),
        actions: [
          // ปุ่มแก้ไข (ข้อ 1.2 Update)
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WordFormScreen(word: word),
                ),
              );
            },
          ),
          // ปุ่มลบ (ข้อ 1.2 Delete) พร้อม Dialog ยืนยัน
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // แสดงคำศัพท์หลัก
            Center(
              child: Column(
                children: [
                  Text(
                    word.word,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(word.type),
                    backgroundColor: Colors.blue.shade100,
                  ),
                ],
              ),
            ),
            const Divider(height: 40),
            
            // รายละเอียดอื่นๆ
            _buildDetailSection('คำแปล (Translation)', word.translation),
            _buildDetailSection('ระดับความยาก (Difficulty)', word.difficulty),
            _buildDetailSection('ตัวอย่างประโยค (Example Sentence)', 
                word.sentence.isNotEmpty ? word.sentence : 'ไม่มีตัวอย่างประโยค'),
            
            const SizedBox(height: 30),
            
            // สถานะการจำ
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: word.isMemorized == 1 ? Colors.green.shade100 : Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      word.isMemorized == 1 ? Icons.check_circle : Icons.help_outline,
                      color: word.isMemorized == 1 ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      word.isMemorized == 1 ? 'จำได้แล้ว' : 'ยังไม่ได้จำ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: word.isMemorized == 1 ? Colors.green.shade900 : Colors.orange.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget ช่วยสร้าง Layout ส่วนแสดงรายละเอียด
  Widget _buildDetailSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 5),
          Text(
            content,
            style: const TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }

  // ฟังก์ชันแสดง Dialog ยืนยันการลบ (ฟีเจอร์เสริมเพื่อคะแนน)
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('คุณแน่ใจหรือไม่ว่าต้องการลบคำว่า "${word.word}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              context.read<WordProvider>().deleteWord(word.id!);
              Navigator.pop(ctx); // ปิด Dialog
              Navigator.pop(context); // กลับไปยังหน้า List
            },
            child: const Text('ลบ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}