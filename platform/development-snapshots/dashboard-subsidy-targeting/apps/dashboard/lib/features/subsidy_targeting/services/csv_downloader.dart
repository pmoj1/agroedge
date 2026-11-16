/// Conditional export: the dashboard ships to Flutter Web only, but this
/// keeps `flutter test` (which runs on the Dart VM, not the web) compiling
/// against a real `downloadCsv` symbol instead of failing to resolve
/// dart:html. See csv_downloader_web.dart for the actual browser download
/// and csv_downloader_stub.dart for the non-web no-op.
library;

export 'csv_downloader_stub.dart'
    if (dart.library.html) 'csv_downloader_web.dart';
