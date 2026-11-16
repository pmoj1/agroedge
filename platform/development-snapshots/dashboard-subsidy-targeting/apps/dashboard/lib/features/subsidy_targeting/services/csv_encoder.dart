/// Minimal RFC-4180-style CSV encoder. No pub dependency is added for this
/// -- the encoding rules needed (quote values containing a comma, quote, or
/// newline; double up embedded quotes) are a handful of lines.
String encodeCsv(List<String> headers, List<List<String>> rows) {
  final buffer = StringBuffer()..writeln(_encodeRow(headers));
  for (final row in rows) {
    buffer.writeln(_encodeRow(row));
  }
  return buffer.toString();
}

String _encodeRow(List<String> values) =>
    values.map(_encodeValue).join(',');

String _encodeValue(String value) {
  final needsQuoting =
      value.contains(',') || value.contains('"') || value.contains('\n');
  if (!needsQuoting) return value;
  return '"${value.replaceAll('"', '""')}"';
}
