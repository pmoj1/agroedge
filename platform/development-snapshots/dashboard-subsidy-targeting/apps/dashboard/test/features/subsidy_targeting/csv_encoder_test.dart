import 'package:agroedge_dashboard/features/subsidy_targeting/services/csv_encoder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('encodeCsv', () {
    test('joins headers and rows with commas and trailing newlines', () {
      final csv = encodeCsv(
        ['District', 'Gap'],
        [
          ['Mahalapye', '32'],
          ['Serowe', '25'],
        ],
      );

      expect(csv, 'District,Gap\nMahalapye,32\nSerowe,25\n');
    });

    test('quotes a value containing a comma', () {
      final csv = encodeCsv(
        ['Reason'],
        [
          ['Delayed, awaiting stock'],
        ],
      );

      expect(csv, 'Reason\n"Delayed, awaiting stock"\n');
    });

    test('quotes and doubles an embedded double quote', () {
      final csv = encodeCsv(
        ['Note'],
        [
          ['Flagged as "duplicate"'],
        ],
      );

      expect(csv, 'Note\n"Flagged as ""duplicate"""\n');
    });

    test('quotes a value containing a newline', () {
      final csv = encodeCsv(
        ['Note'],
        [
          ['Line one\nLine two'],
        ],
      );

      expect(csv, 'Note\n"Line one\nLine two"\n');
    });

    test('leaves a plain value unquoted', () {
      final csv = encodeCsv(
        ['District'],
        [
          ['Tonota'],
        ],
      );

      expect(csv, 'District\nTonota\n');
    });
  });
}
