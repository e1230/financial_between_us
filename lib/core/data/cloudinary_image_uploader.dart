import 'dart:convert';

import 'package:http/http.dart' as http;

/// An image could not be uploaded (network, preset or server error).
class ImageUploadException implements Exception {
  const ImageUploadException(this.message);

  final String message;

  @override
  String toString() => 'ImageUploadException: $message';
}

/// An uploaded image, as Cloudinary describes it.
final class UploadedImage {
  const UploadedImage({
    required this.url,
    this.width = 0,
    this.height = 0,
    this.bytes = 0,
  });

  /// Public `secure_url`.
  final String url;
  final int width;
  final int height;
  final int bytes;
}

/// Unsigned upload of images to Cloudinary (upload preset). The API secret
/// never reaches the app.
class CloudinaryImageUploader {
  CloudinaryImageUploader({
    required this.cloudName,
    required this.uploadPreset,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String cloudName;
  final String uploadPreset;
  final http.Client _client;

  static const Duration _timeout = Duration(seconds: 60);

  Uri get _endpoint =>
      Uri.https('api.cloudinary.com', '/v1_1/$cloudName/image/upload');

  /// Uploads the image at [filePath] into [folder]. Throws
  /// [ImageUploadException].
  Future<UploadedImage> upload(
    String filePath, {
    required String folder,
  }) async {
    if (cloudName.isEmpty || uploadPreset.isEmpty) {
      throw const ImageUploadException('Cloudinary is not configured');
    }
    final request = http.MultipartRequest('POST', _endpoint)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = folder
      ..files.add(await http.MultipartFile.fromPath('file', filePath));

    final http.Response response;
    try {
      response = await http.Response.fromStream(
        await _client.send(request).timeout(_timeout),
      );
    } on Exception catch (error) {
      throw ImageUploadException('Request failed: $error');
    }

    if (response.statusCode != 200) {
      throw ImageUploadException(
        'HTTP ${response.statusCode}: ${response.body}',
      );
    }
    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) {
      throw const ImageUploadException('Unexpected response');
    }
    final url = body['secure_url'];
    if (url is! String || url.isEmpty) {
      throw const ImageUploadException('Response without secure_url');
    }
    int number(String key) => body[key] is int ? body[key] as int : 0;
    return UploadedImage(
      url: url,
      width: number('width'),
      height: number('height'),
      bytes: number('bytes'),
    );
  }
}
