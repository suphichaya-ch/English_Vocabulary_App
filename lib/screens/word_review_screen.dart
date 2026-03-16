import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/word_model.dart';
import '../providers/word_provider.dart';

class WordReviewScreen extends StatefulWidget {
  const WordReviewScreen({super.key});

  @override
  State<WordReviewScreen> createState() => _WordReviewScreenState();
}

class _WordReviewScreenState extends State<WordReviewScreen> {
  Word? currentWord;
  bool showTranslation = false;

  @override
  void initState() {
    super.initState();
    // ดึงคำศัพท์จริงที่ยังจำไม่ได้จาก Provider มาสุ่มโชว์
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNewWord();
    });
  }

  void _loadNewWord() {
    setState(() {
      showTranslation = false;
      currentWord = context.read<WordProvider>().getRandomPendingWord();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ทบทวนคำศัพท์จริง'), centerTitle: true),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        child: currentWord == null
            ? _buildEmptyState()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // การ์ดคำศัพท์ (Flashcard)
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => showTranslation = !showTranslation),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: showTranslation
                              ? Colors.white
                              : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.blue.shade200,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // ประเภทของคำ (Tag)
                            Chip(
                              label: Text(currentWord!.type),
                              backgroundColor: Colors.blue.withOpacity(0.1),
                            ),
                            const SizedBox(height: 20),
                            // คำศัพท์ภาษาอังกฤษ
                            Text(
                              currentWord!.word,
                              style: const TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 30),
                            // ส่วนเฉลย
                            if (showTranslation) ...[
                              const Divider(indent: 50, endIndent: 50),
                              const SizedBox(height: 20),
                              Text(
                                currentWord!.translation,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Text(
                                  'Example: ${currentWord!.sentence}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey.shade600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ] else ...[
                              const Text(
                                '(แตะเพื่อดูคำแปล)',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // ปุ่มควบคุม
                  _buildControlButtons(),
                ],
              ),
      ),
    );
  }

  // หน้าจอเมื่อจำได้ครบหมดแล้ว
  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.stars, size: 100, color: Colors.orange),
        const SizedBox(height: 20),
        const Text(
          'เก่งมากครับ Pop!\nคุณจำคำศัพท์ได้ครบหมดแล้ว',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('กลับไปหน้าหลัก'),
        ),
      ],
    );
  }

  // ปุ่มกดด้านล่าง
  Widget _buildControlButtons() {
    if (!showTranslation) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(200, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: () => setState(() => showTranslation = true),
        child: const Text('ดูเฉลย', style: TextStyle(fontSize: 18)),
      );
    }

    return Row(
      children: [
        // ปุ่มจำไม่ได้ (ข้ามไปก่อน)
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 55),
              side: const BorderSide(color: Colors.blue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onPressed: _loadNewWord,
            icon: const Icon(Icons.refresh),
            label: const Text('ข้าม/คำต่อไป'),
          ),
        ),
        const SizedBox(width: 15),
        // ปุ่มจำได้แล้ว (อัปเดตลง Database)
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onPressed: () {
              // สั่ง Provider อัปเดตข้อมูลจริงใน DB
              currentWord!.isMemorized = 1;
              context.read<WordProvider>().updateWord(currentWord!);
              _loadNewWord();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('บันทึกความสำเร็จแล้ว! ✅'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            icon: const Icon(Icons.check),
            label: const Text('จำได้แล้ว'),
          ),
        ),
      ],
    );
  }
}
