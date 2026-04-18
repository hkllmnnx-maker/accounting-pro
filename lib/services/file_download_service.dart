import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:share_plus/share_plus.dart';

// Conditional import: dart:html on web, stub on others.
import 'web_download_stub.dart'
    if (dart.library.html) 'web_download_web.dart' as web_dl;

/// Cross-platform service to "download" / save / share text files.
/// On Web: triggers a real browser download.
/// On Mobile/Desktop: uses share_plus to share the file.
class FileDownloadService {
  /// Save / download a UTF-8 text file with the given content.
  /// [filename] should include the extension (e.g. "clients.csv").
  static Future<void> downloadText({
    required String filename,
    required String content,
    String mimeType = 'text/csv;charset=utf-8',
  }) async {
    if (kIsWeb) {
      web_dl.downloadBytes(
        filename: filename,
        bytes: Uint8List.fromList(utf8.encode(content)),
        mimeType: mimeType,
      );
      return;
    }
    // Mobile / Desktop: share via XFile in-memory.
    final bytes = Uint8List.fromList(utf8.encode(content));
    await Share.shareXFiles(
      [XFile.fromData(bytes, name: filename, mimeType: mimeType)],
    );
  }
}
