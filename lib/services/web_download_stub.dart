import 'dart:typed_data';

/// Non-web stub. Web implementation lives in `web_download_web.dart`.
void downloadBytes({
  required String filename,
  required Uint8List bytes,
  required String mimeType,
}) {
  // No-op on non-web platforms; mobile flow uses share_plus instead.
}
