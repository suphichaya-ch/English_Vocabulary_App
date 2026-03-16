import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/word_provider.dart';
import 'word_list_screen.dart';
import 'word_form_screen.dart';
import 'word_review_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WordProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.red),
            onPressed: () => _showClearAllDialog(context, provider),
            tooltip: 'ล้างข้อมูลทั้งหมด',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ยินดีต้อนรับ, Suphichaya',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text('สถิติการเรียนรู้คำศัพท์ของคุณ'),
            const SizedBox(height: 20),

            // StatCard
            Row(
              children: [
                _buildStatCard('ทั้งหมด', provider.totalCount, Colors.blue),
                _buildStatCard(
                  'จำได้แล้ว',
                  provider.memorizedCount,
                  Colors.green,
                ),
                _buildStatCard(
                  'ต้องทบทวน',
                  provider.pendingCount,
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tag Count
            const Text(
              'แยกตามประเภทคำ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTagCount(
                    'Noun',
                    provider.countByType('Noun'),
                    Colors.blue,
                  ),
                  _buildTagCount(
                    'Verb',
                    provider.countByType('Verb'),
                    Colors.red,
                  ),
                  _buildTagCount(
                    'Adj',
                    provider.countByType('Adj'),
                    Colors.green,
                  ),
                  _buildTagCount(
                    'Adv',
                    provider.countByType('Adv'),
                    Colors.orange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // เมนูหลัก
            _buildMenuButton(
              context,
              icon: Icons.list,
              label: 'ดูรายการคำศัพท์ทั้งหมด',
              color: Colors.blue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WordListScreen()),
              ),
            ),
            const SizedBox(height: 15),
            _buildMenuButton(
              context,
              icon: Icons.psychology,
              label: 'โหมดทบทวนคำศัพท์',
              color: Colors.orange,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WordReviewScreen()),
              ),
            ),
            const SizedBox(height: 15),
            _buildMenuButton(
              context,
              icon: Icons.add_circle_outline,
              label: 'เพิ่มคำศัพท์ใหม่',
              color: Colors.purple,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WordFormScreen()),
              ),
            ),
            const SizedBox(height: 20),

            // ปุ่มโหลดคำศัพท์จากพจนานุกรม JSON
            Center(
              child: TextButton.icon(
                onPressed: () async {
                  try {
                    await provider
                        .addWordsFromDictionary(); // เรียกฟังก์ชันตรงชื่อ
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('โหลดคำศัพท์จากพจนานุกรมเรียบร้อย!'),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
                    );
                  }
                },
                icon: const Icon(Icons.library_books),
                label: const Text('โหลดคำศัพท์จากพจนานุกรม'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WordFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCard(String label, int value, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        color: color.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTagCount(String label, int count, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(width: 20),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color.withOpacity(0.8),
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: color),
          ],
        ),
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, WordProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันการลบทั้งหมด'),
        content: const Text(
          'คุณแน่ใจหรือไม่ว่าต้องการลบคำศัพท์ทุกคำออกจากระบบ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () async {
              await provider.clearAllWords();
              Navigator.pop(ctx);
            },
            child: const Text('ลบทั้งหมด', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
