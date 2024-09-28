import 'dart:async';

import 'package:flutter/material.dart';

class TypingText extends StatefulWidget {
  final String text;
  final TextStyle? textStyle;
  final Duration typingSpeed;
  final VoidCallback? onCompleted;

  const TypingText({
    super.key,
    required this.text,
    this.textStyle,
    this.typingSpeed = const Duration(milliseconds: 100),
    this.onCompleted,
  });

  @override
  TypingTextState createState() => TypingTextState();
}

class TypingTextState extends State<TypingText> {
  String _displayedText = '';
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    _timer = Timer.periodic(widget.typingSpeed, (Timer timer) {
      if (_currentIndex < widget.text.length) {
        setState(() {
          _displayedText += widget.text[_currentIndex];
          _currentIndex++;
        });
      } else {
        _timer?.cancel();
        if (widget.onCompleted != null) {
          widget.onCompleted!();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      style: widget.textStyle,
    );
  }
}
