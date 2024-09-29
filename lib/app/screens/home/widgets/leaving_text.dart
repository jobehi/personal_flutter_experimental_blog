import 'package:flutter/material.dart';
import 'package:youssef_el_behi/app/screens/shared/widgets/text_typer.dart';

class LeavingText extends StatefulWidget {
  const LeavingText({super.key});

  @override
  LeavingTextState createState() => LeavingTextState();
}

class LeavingTextState extends State<LeavingText> {
  bool displayAnswers = false; // Initialize to false to hide buttons initially

  // Replace this with your actual text
  final String leavingText = "Wait... Are you leaving already?";
  bool displayYes = true;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Column(
        children: [
          TypingText(
            typingSpeed: const Duration(milliseconds: 100),
            text: leavingText,
            textStyle: const TextStyle(
              fontSize: 20,
            ),
            onCompleted: () {
              setState(() {
                displayAnswers = true;
              });
            },
          ),
          const SizedBox(height: 20),
          AnimatedOpacity(
              curve: Curves.easeInOut,
              duration: const Duration(seconds: 1),
              opacity: displayAnswers ? 1 : 0,
              child: _buildAnswerButtons()),
        ],
      ),
    );
  }

  Widget _buildAnswerButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _handleNo,
            child: const Text('No'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: MouseRegion(
            onExit: (event) {
              setState(() {
                displayYes = true;
              });
            },
            child: displayYes
                ? ElevatedButton(
                    onPressed: () {
                      setState(() {
                        displayYes = false;
                      });
                    },
                    child: const Text('Yes'),
                  )
                : ElevatedButton(
                    onPressed: _handleNo,
                    child: const Text('No'),
                  ),
          ),
        ),
      ],
    );
  }

  void _handleNo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You pressed No!')),
    );
  }
}
