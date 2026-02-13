import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai.freezed.dart';
part 'ai.g.dart';

@freezed
abstract class ImageData with _$ImageData {
  const factory ImageData({required String url, String? size}) = _ImageData;

  factory ImageData.fromJson(Map<String, dynamic> json) =>
      _$ImageDataFromJson(json);
}

@freezed
abstract class ApiError with _$ApiError {
  const factory ApiError({required String code, required String message}) =
      _ApiError;

  factory ApiError.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorFromJson(json);
}

@freezed
abstract class ImageUsage with _$ImageUsage {
  const factory ImageUsage({
    required int generatedImages,
    required int totalTokens,
  }) = _ImageUsage;
  factory ImageUsage.fromJson(Map<String, dynamic> json) =>
      _$ImageUsageFromJson(json);
}

@freezed
sealed class ImageGenerationResponse with _$ImageGenerationResponse {
  const factory ImageGenerationResponse.success({
    String? model,
    int? created,
    required List<ImageData> data,
    ImageUsage? usage,
  }) = _Success;

  const factory ImageGenerationResponse.error({required ApiError error}) =
      _Error;

  factory ImageGenerationResponse.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('error') && json['error'] != null) {
      return ImageGenerationResponse.error(
        error: ApiError.fromJson(json['error'] as Map<String, dynamic>),
      );
    }
    return ImageGenerationResponse.success(
      model: json['model'],
      created: json['created'],
      data: (json['data'] as List<dynamic>)
          .map((e) => ImageData.fromJson(e as Map<String, dynamic>))
          .toList(),
      usage: json['usage'] != null
          ? ImageUsage.fromJson(json['usage'] as Map<String, dynamic>)
          : null,
    );
  }
}

class VolcengineHttpClient {
  static const String baseUrl =
      'https://ark.cn-beijing.volces.com/api/v3/images/generations';
  final String apiKey;

  VolcengineHttpClient({required this.apiKey});
  Future<ImageGenerationResponse> generateImage({
    required String model,
    required String prompt,
    String size = "2K",
    String responseFormat = "url",
    bool watermark = false,
  }) async {
    final Uri url = Uri.parse(baseUrl);

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final Map<String, dynamic> body = {
      "model": model,
      "prompt": prompt,
      "size": size,
      "response_format": responseFormat,
      "stream": false,
      "watermark": watermark,
    };

    try {
      final response = await http
          .post(url, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 60));

      final Map<String, dynamic> jsonMap = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      final apiResponse = ImageGenerationResponse.fromJson(jsonMap);
      return apiResponse;
    } catch (e) {
      return ImageGenerationResponse.error(
        error: ApiError(
          code: HttpStatus.internalServerError.toString(),
          message: e.toString(),
        ),
      );
    }
  }
}
