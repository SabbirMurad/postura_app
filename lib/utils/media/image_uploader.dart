part of '../media.dart';

enum AssetUsedAt { ProfilePic, Capture, Signature }

/// Uploads [images] to the server and returns their assigned IDs.
///
/// Throws if any image in the list is still being prepared.
Future<List<String>?> upload_images({
  required List<PreparedImage> images,
  required AssetUsedAt used_at,
  bool temporary = true,
}) async {
  for (final image in images) {
    if (!image.prepared) throw StateError('Image is not prepared.');
  }

  final uri = Uri.parse('${AppCredentials.domain}/image');

  // The upload endpoint requires authentication. Build a fresh request each send
  // (multipart bodies are single-use) with the current bearer token.
  Future<http.StreamedResponse> send(String? token) {
    final request = http.MultipartRequest('POST', uri);
    if (token != null) request.headers['Authorization'] = 'Bearer $token';

    for (int i = 0; i < images.length; i++) {
      final prepared = images[i];
      final meta = prepared.meta!;

      request.files.add(
        http.MultipartFile.fromBytes(
          'image_$i',
          meta.compressed_bytes,
          filename: 'image_$i.jpg',
        ),
      );

      request.fields['width_$i'] = '${meta.width}';
      request.fields['height_$i'] = '${meta.height}';
      request.fields['blur_hash_$i'] = meta.blur_hash;
      request.fields['used_at_$i'] = used_at.name;
      request.fields['temporary_$i'] = temporary.toString();
    }

    return request.send();
  }

  var response = await send(await AppHelper.instance.getAccessToken());

  // This request bypasses CustomHttp, so refresh + retry once on a 401.
  if (response.statusCode == 401 && await CustomHttp.setNewAccessToken()) {
    response = await send(await AppHelper.instance.getAccessToken());
  }

  if (response.statusCode == 200) {
    final body = await response.stream.bytesToString();
    final json = jsonDecode(body) as List<dynamic>;
    return json.cast<String>();
  }

  printLine(
    'Image upload failed (${response.statusCode}): '
    '${await response.stream.bytesToString()}',
  );
  return null;
}
