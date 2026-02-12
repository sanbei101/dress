import 'package:dress/main.dart';
import 'package:dress/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

@immutable
class UserPrefs {
  final String gender;
  final List<String> selectedStyles;
  final List<String> colors;

  const UserPrefs({
    this.gender = '女',
    this.selectedStyles = const [],
    this.colors = const [],
  });

  UserPrefs copyWith({
    String? gender,
    List<String>? selectedStyles,
    List<String>? colors,
  }) {
    return UserPrefs(
      gender: gender ?? this.gender,
      selectedStyles: selectedStyles ?? this.selectedStyles,
      colors: colors ?? this.colors,
    );
  }
}

class UserPrefsNotifier extends Notifier<UserPrefs> {
  @override
  UserPrefs build() => const UserPrefs();

  void setGender(String gender) => state = state.copyWith(gender: gender);

  void toggleStyle(String style) {
    final list = List<String>.from(state.selectedStyles);
    list.contains(style) ? list.remove(style) : list.add(style);
    state = state.copyWith(selectedStyles: list);
  }

  void toggleColor(String color) {
    final list = List<String>.from(state.colors);
    list.contains(color) ? list.remove(color) : list.add(color);
    state = state.copyWith(colors: list);
  }
}

final userPrefsProvider = NotifierProvider<UserPrefsNotifier, UserPrefs>(
  UserPrefsNotifier.new,
);

const styles = ["休闲", "商务", "街头", "极简", "复古", "运动"];
const colors = ["黑色", "白色", "藏青", "米色"];

class PreferenceScreen extends ConsumerWidget {
  const PreferenceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(userPrefsProvider);
    return Scaffold(
      appBar: AppBar(
        actions: [TextButton(onPressed: () {}, child: const Text("跳过"))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("打造您的风格", style: context.textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(
            "回答几个问题,让我们为您推荐完美的穿搭",
            style: context.textTheme.labelMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          const Text("您想看谁的穿搭?", style: TextStyle(fontWeight: FontWeight.bold)),

          RadioGroup<String>(
            groupValue: prefs.gender,
            onChanged: (v) {
              ref.read(userPrefsProvider.notifier).setGender(v!);
            },
            child: const Column(
              children: [
                RadioListTile<String>(title: Text("女士"), value: '女'),
                RadioListTile<String>(title: Text("男士"), value: '男'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "您喜欢的风格 (${prefs.selectedStyles.length})",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Column(
            children: styles.map((style) {
              return CheckboxListTile(
                title: Text(style),
                value: prefs.selectedStyles.contains(style),
                onChanged: (_) =>
                    ref.read(userPrefsProvider.notifier).toggleStyle(style),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          const Text("您喜欢的配色", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: colors.map((color) {
              return ChoiceChip(
                label: Text(color),
                selected: prefs.colors.contains(color),
                onSelected: (_) =>
                    ref.read(userPrefsProvider.notifier).toggleColor(color),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // 穿搭 Agent 按钮
          FilledButton(
            onPressed: () {
              context.pushNamed(AppRoute.outfitAgent.name);
            },
            child: const Text("进入穿搭 Agent"),
          ),
        ],
      ),
    );
  }
}
