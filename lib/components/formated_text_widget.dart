import 'package:flutter/material.dart';

class FormattedTextWidget extends StatelessWidget {
  final String inputText;
  final TextStyle defaultStyle;

  const FormattedTextWidget(
      {super.key,
      required this.inputText,
      this.defaultStyle = const TextStyle(color: Colors.black)});

  // Function to parse the input text and convert it to a list of TextSpans with different styles
  List<TextSpan> _parseText(String text) {
    List<TextSpan> spans = [];
    final RegExp regex = RegExp(
        r'(\*\*.*?\*\*|\_.*?\_|# .*?|\- .+?|\n)'); // Pattern to detect different formats

    // Split the input text based on the regex
    Iterable<Match> matches = regex.allMatches(text);

    int lastMatchEnd = 0;
    for (final match in matches) {
      final matchedText = match.group(0)!;

      // Text before this match should be normal
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
            text: text.substring(lastMatchEnd, match.start),
            style: defaultStyle));
      }

      // Handle different types of formatted text
      if (matchedText.startsWith('**') && matchedText.endsWith('**')) {
        spans.add(TextSpan(
            text: matchedText.substring(2, matchedText.length - 2),
            style: defaultStyle.copyWith(fontWeight: FontWeight.bold)));
      } else if (matchedText.startsWith('_') && matchedText.endsWith('_')) {
        spans.add(TextSpan(
            text: matchedText.substring(1, matchedText.length - 1),
            style: defaultStyle.copyWith(fontStyle: FontStyle.italic)));
      } else if (matchedText.startsWith('# ')) {
        spans.add(TextSpan(
            text: matchedText.substring(2),
            style: defaultStyle.copyWith(
                fontSize: 24, fontWeight: FontWeight.bold)));
      } else if (matchedText.startsWith('- ')) {
        spans.add(TextSpan(
            text: '• ' + matchedText.substring(2),
            style: defaultStyle.copyWith(fontSize: 18, color: Colors.black54)));
      } else {
        spans.add(TextSpan(text: matchedText, style: defaultStyle));
      }

      lastMatchEnd = match.end;
    }

    // Add any remaining text after the last match
    if (lastMatchEnd < text.length) {
      spans.add(
          TextSpan(text: text.substring(lastMatchEnd), style: defaultStyle));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: _parseText(inputText),
        style: defaultStyle, // Apply the default style here
      ),
    );
  }
}
