import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

Future<File?> compressImage(String filePath) async {
  try {
    final tempDir = await getTemporaryDirectory();
    final targetPath =
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      filePath,
      targetPath,
      quality: 75, // 🔥 balance quality vs size
      minWidth: 1080,
      minHeight: 1080,
    );

    if (result == null) return null;

    return File(result.path);
  } catch (e) {
    return null;
  }
}