import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

/// Triggers a browser download of [csvContent] as [filename]. dart:html is
/// deprecated in favour of package:web, but adding a new pub dependency for
/// this is a "stop and ask" per apps/CLAUDE.md -- dart:html still compiles
/// and works on the stable web renderer this project targets.
void downloadCsv(String filename, String csvContent) {
  final bytes = utf8.encode(csvContent);
  final blob = html.Blob([bytes], 'text/csv;charset=utf-8');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}
