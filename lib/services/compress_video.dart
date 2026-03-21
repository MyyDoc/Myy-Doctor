import 'dart:io';

import 'package:video_compress/video_compress.dart';

Future<File?> compressVideo(String videoPath) async {
  try {
    final info = await VideoCompress.compressVideo(
      videoPath,
      quality: VideoQuality.MediumQuality, // 🔥 best balance
      deleteOrigin: false, // DO NOT delete original
      includeAudio: true,
    );

    if (info == null || info.file == null) return null;

    return info.file;
  } catch (e) {
    return null;
  }
}