import 'package:dress/theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const OutfitApp());
}

class OutfitApp extends StatelessWidget {
  const OutfitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Outfit Recommendation',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const PreferenceScreen(),
    );
  }
}

class PreferenceScreen extends StatefulWidget {
  const PreferenceScreen({super.key});

  @override
  State<PreferenceScreen> createState() => _PreferenceScreenState();
}

class _PreferenceScreenState extends State<PreferenceScreen> {
  String _selectedGender = '女';
  final List<String> _selectedStyles = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.close),
        actions: [TextButton(onPressed: () {}, child: const Text("跳过"))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "打造您的风格",
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "回答几个问题，让我们为您推荐完美的穿搭。",
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 32),
            Text("您想看谁的穿搭？", style: context.textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildGenderCard(
                    "👩",
                    "女士",
                    _selectedGender == '女',
                    () => setState(() => _selectedGender = '女'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildGenderCard(
                    "👨",
                    "男士",
                    _selectedGender == '男',
                    () => setState(() => _selectedGender = '男'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
            Text("您喜欢的风格 (选3个)", style: context.textTheme.titleMedium),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _buildStyleChip("🧢", "休闲 (Casual)"),
                _buildStyleChip("💼", "商务 (Business)"),
                _buildStyleChip("👟", "街头 (Street)"),
                _buildStyleChip("⚪", "极简 (Minimalist)"),
                _buildStyleChip("🎞️", "复古 (Vintage)"),
                _buildStyleChip("🏃", "运动 (Sporty)"),
              ],
            ),

            const SizedBox(height: 32),
            Text("您喜欢的配色", style: context.textTheme.titleMedium),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildColorChip("黑色", Colors.black, Colors.white),
                _buildColorChip(
                  "白色",
                  Colors.white,
                  Colors.black,
                  hasBorder: true,
                ),
                _buildColorChip("藏青", const Color(0xFF1A358F), Colors.white),
                _buildColorChip("米色", const Color(0xFFF5F5DC), Colors.black87),
                _buildColorChip("淡彩", const Color(0xFFFFE4F2), Colors.black87),
                _buildColorChip("鲜艳", const Color(0xFFFF3B30), Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 辅助组件：性别选择卡片
  Widget _buildGenderCard(
    String emoji,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: isSelected ? Colors.transparent : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildStyleChip(String emoji, String label) {
    bool isSelected = _selectedStyles.contains(label);
    return InkWell(
      onTap: () => setState(
        () => isSelected
            ? _selectedStyles.remove(label)
            : _selectedStyles.add(label),
      ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Text(emoji),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorChip(
    String label,
    Color bgColor,
    Color textColor, {
    bool hasBorder = false,
  }) {
    return Container(
      width: (MediaQuery.of(context).size.width - 72) / 3, // 三列布局
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: hasBorder ? Border.all(color: Colors.grey.shade300) : null,
        boxShadow: [
          if (hasBorder)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 4,
            ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
    );
  }
}
