import 'package:dress/index.dart';
import 'package:dress/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final clothingTypes = ["上衣", "裤子", "裙子", "外套", "鞋子", "配饰"];

final upperStyles = ["T恤", "衬衫", "毛衣", "卫衣", "西装外套", "夹克"];
final bottomStyles = ["牛仔裤", "休闲裤", "短裤", "运动裤"];
final skirtStyles = ["长裙", "短裙", "A字裙", "百褶裙"];
final outerStyles = ["大衣", "羽绒服", "风衣", "西装", "皮夹克"];
final shoeStyles = ["运动鞋", "皮鞋", "靴子", "凉鞋", "拖鞋"];
final accessoryStyles = ["帽子", "围巾", "腰带", "包", "首饰"];

class OutfitAgentState {
  final String? selectedType;
  final List<String> selectedStyles;
  final bool isLoading;
  final bool isFavorite;
  final String? generatedImageUrl;

  OutfitAgentState({
    this.selectedType,
    this.selectedStyles = const [],
    this.isLoading = false,
    this.isFavorite = false,
    this.generatedImageUrl,
  });

  OutfitAgentState copyWith({
    String? selectedType,
    List<String>? selectedStyles,
    bool? isLoading,
    bool? isFavorite,
    String? generatedImageUrl,
  }) {
    return OutfitAgentState(
      selectedType: selectedType ?? this.selectedType,
      selectedStyles: selectedStyles ?? this.selectedStyles,
      isLoading: isLoading ?? this.isLoading,
      isFavorite: isFavorite ?? this.isFavorite,
      generatedImageUrl: generatedImageUrl ?? this.generatedImageUrl,
    );
  }
}

class OutfitAgentNotifier extends Notifier<OutfitAgentState> {
  @override
  OutfitAgentState build() => OutfitAgentState();

  void selectType(String type) {
    state = state.copyWith(selectedType: type, selectedStyles: []);
  }

  void toggleStyle(String style) {
    final list = List<String>.from(state.selectedStyles);
    list.contains(style) ? list.remove(style) : list.add(style);
    state = state.copyWith(selectedStyles: list);
  }

  void toggleFavorite() {
    state = state.copyWith(isFavorite: !state.isFavorite);
  }

  Future<void> generateOutfit() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 2));
    state = state.copyWith(
      isLoading: false,
      generatedImageUrl: 'https://via.placeholder.com/300x400?text=AI+生成的穿搭',
    );
  }

  void reset() {
    state = OutfitAgentState();
  }
}

final outfitAgentProvider =
    NotifierProvider<OutfitAgentNotifier, OutfitAgentState>(
      OutfitAgentNotifier.new,
    );

class OutfitAgentScreen extends ConsumerWidget {
  const OutfitAgentScreen({super.key});

  List<String> _getStylesForType(String? type) {
    switch (type) {
      case "上衣":
        return upperStyles;
      case "裤子":
        return bottomStyles;
      case "裙子":
        return skirtStyles;
      case "外套":
        return outerStyles;
      case "鞋子":
        return shoeStyles;
      case "配饰":
        return accessoryStyles;
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(outfitAgentProvider);
    final prefs = ref.watch(userPrefsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("穿搭 Agent")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("您的偏好", style: context.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text("性别: ${prefs.gender}"),
                  Text(
                    "风格: ${prefs.selectedStyles.isEmpty ? '未选择' : prefs.selectedStyles.join(', ')}",
                  ),
                  Text(
                    "配色: ${prefs.colors.isEmpty ? '未选择' : prefs.colors.join(', ')}",
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          const Text("选择服装类型", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: clothingTypes.map((type) {
              return ChoiceChip(
                label: Text(type),
                selected: state.selectedType == type,
                onSelected: (_) {
                  ref.read(outfitAgentProvider.notifier).selectType(type);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          if (state.selectedType != null) ...[
            Text(
              "选择${state.selectedType}款式",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._getStylesForType(state.selectedType).map((style) {
              return CheckboxListTile(
                title: Text(style),
                value: state.selectedStyles.contains(style),
                onChanged: (_) {
                  ref.read(outfitAgentProvider.notifier).toggleStyle(style);
                },
              );
            }),
            const SizedBox(height: 16),
          ],

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.selectedStyles.isNotEmpty && !state.isLoading
                  ? () {
                      ref.read(outfitAgentProvider.notifier).generateOutfit();
                    }
                  : null,
              child: const Text("生成穿搭"),
            ),
          ),
          const SizedBox(height: 16),

          if (state.isLoading)
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text("AI 正在生成您的穿搭..."),
                ],
              ),
            ),

          if (state.generatedImageUrl != null && !state.isLoading) ...[
            const Text("生成的穿搭", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Image.network(
                    state.generatedImageUrl!,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return SizedBox(
                        height: 300,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 64),
                              const Text("图片加载失败"),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: Text(
                      "${state.selectedType}: ${state.selectedStyles.join(', ')}",
                    ),
                    subtitle: const Text("根据您的偏好生成"),
                    trailing: IconButton(
                      icon: Icon(
                        state.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: state.isFavorite ? Colors.red : null,
                      ),
                      onPressed: () {
                        ref.read(outfitAgentProvider.notifier).toggleFavorite();
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  ref.read(outfitAgentProvider.notifier).reset();
                },
                child: const Text("重新生成"),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
