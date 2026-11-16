/// No-op fallback selected on the Dart VM (tests). The dashboard ships to
/// Flutter Web only, where csv_downloader_web.dart provides the real
/// implementation.
void downloadCsv(String filename, String csvContent) {}
