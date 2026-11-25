import 'dart:convert';

import 'package:http/http.dart' as http;

/// The avatar could not be uploaded (network, preset or server error).
class AvatarUploadException implements Exception {
  const AvatarUploadException(this.message);

  final String message;

  @override
  String toString() => 'AvatarUploadException: $message';
}

/// Uploads avatar images and returns their public URL.
abstract interface class AvatarUploader {
  /// Uploads the image at [filePath]. Throws [AvatarUploadException].
  Future<String> upload(String filePath);
}

/// Unsigned upload to Cloudinary (upload preset). The API secret never
/// reaches the app.
class CloudinaryAvatarUploader implements AvatarUploader {
  CloudinaryAvatarUploader({
    required this.cloudName,
    required this.uploadPreset,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String cloudName;
  final String uploadPreset;
  final http.Client _client;

  /// Cloudinary folder of the avatars.
  static const String folder = 'fbu/avatars';

  static const Duration _timeout = Duration(seconds: 60);

  Uri get _endpoint =>
      Uri.https('api.cloudinary.com', '/v1_1/$cloudName/image/upload');

  @override
  Future<String> upload(String filePath) async {
    if (cloudName.isEmpty || uploadPreset.isEmpty) {
      throw const AvatarUploadException('Cloudinary is not configured');
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
      throw AvatarUploadException('Request failed: $error');
    }

    if (response.statusCode != 200) {
      throw AvatarUploadException(
        'HTTP ${response.statusCode}: ${response.body}',
      );
    }
    final body = jsonDecode(response.body);
    final url = body is Map<String, dynamic> ? body['secure_url'] : null;
    if (url is! String || url.isEmpty) {
      throw const AvatarUploadException('Response without secure_url');
    }
    return url;
  }
}
