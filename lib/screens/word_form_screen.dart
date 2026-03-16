import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/word_model.dart';
import '../providers/word_provider.dart';

class WordFormScreen extends StatefulWidget {
  final Word? word; // ถ้ามีข้อมูลส่งมา = แก้ไข, ถ้าไม่มี = เพิ่มใหม่

  const WordFormScreen({Key? key, this.word}) : super(key: key);

  @override
  State<WordFormScreen> createState() => _WordFormScreenState();
}

class _WordFormScreenState extends State<WordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers สำหรับดึงค่าจากช่องกรอก
  late TextEditingController _wordController;
  late TextEditingController _translationController;
  late TextEditingController _sentenceController;
  
  String _selectedType = 'Noun';
  String _selectedDifficulty = 'Easy';
  bool _isMemorized = false;

  @override
  void initState() {
    super.initState();
    // ถ้าเป็นการแก้ไข ให้ดึงค่าเก่ามาใส่ในช่องกรอก
    _wordController = TextEditingController(text: widget.word?.word ?? '');
    _translationController = TextEditingController(text: widget.word?.translation ?? '');
    _sentenceController = TextEditingController(text: widget.word?.sentence ?? '');
    _selectedType = widget.word?.type ?? 'Noun';
    _selectedDifficulty = widget.word?.difficulty ?? 'Easy';
    _isMemorized = widget.word?.isMemorized == 1;
  }

  void _saveForm() {
    // ข้อ 9: ป้องกันการกรอกข้อมูลไม่ครบ (Validation)
    if (_formKey.currentState!.validate()) {
      final newWord = Word(
        id: widget.word?.id,
        word: _wordController.text,
        translation: _translationController.text,
        type: _selectedType,
        difficulty: _selectedDifficulty,
        sentence: _sentenceController.text,
        isMemorized: _isMemorized ? 1 : 0,
      );

      if (widget.word == null) {
        context.read<WordProvider>().addWord(newWord);
      } else {
        context.read<WordProvider>().updateWord(newWord);
      }

      // ข้อ 8: แจ้งเตือนเมื่อบันทึกสำเร็จ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกข้อมูลเรียบร้อยแล้ว'), backgroundColor: Colors.green),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.word == null ? 'เพิ่มคำศัพท์ใหม่' : 'แก้ไขคำศัพท์')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _wordController,
              decoration: const InputDecoration(labelText: 'คำศัพท์ (English)', border: OutlineInputBorder()),
              validator: (value) => value!.isEmpty ? 'กรุณากรอกคำศัพท์' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _translationController,
              decoration: const InputDecoration(labelText: 'คำแปล (Thai)', border: OutlineInputBorder()),
              validator: (value) => value!.isEmpty ? 'กรุณากรอกคำแปล' : null,
            ),
            const SizedBox(height: 16),
            // ฟีเจอร์เสริม: Dropdown สำหรับประเภทคำ
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'ประเภทคำ', border: OutlineInputBorder()),
              items: ['Noun', 'Verb', 'Adj', 'Adv'].map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (val) => setState(() => _selectedType = val!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _sentenceController,
              decoration: const InputDecoration(labelText: 'ตัวอย่างประโยค', border: OutlineInputBorder()),
              maxLines: 2,
            ),
            SwitchListTile(
              title: const Text('จำได้แล้ว'),
              value: _isMemorized,
              onChanged: (val) => setState(() => _isMemorized = val),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveForm,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
              child: const Text('บันทึกข้อมูล', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}