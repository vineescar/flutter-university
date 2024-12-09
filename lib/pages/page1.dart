import 'package:flutter/material.dart';
import '../common_app_bar.dart';
import 'package:http/http.dart' as http;

class Page1 extends StatefulWidget {
  const Page1({super.key});

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  bool isPressed = false;
  Map<String, bool> buttonState = {
    "up": false,
    "left": false,
    "right": false,
    "down": false,
  };


  void _printContinuously(String direction, int value) async {
    setState(() {
      buttonState[direction] = true;
    });

    isPressed = true;
    while (isPressed) {
      // Print the value for debugging
      print(value);

      // Send the POST request
      try {
        final response = await http.post(
          Uri.parse('http://192.168.8.150/message'), // Your ESP32 server URL
          headers: {'Content-Type': 'text/plain'}, // Set the content type to plain text
          body: value.toString(), // Send the value as plain text
        );

        if (response.statusCode == 200) {
          // If the server responds with status 200, print the response
          print('POST request successful: ${response.body}');
        } else {
          // If the server responds with an error, print the status code
          print('Failed to send POST request: ${response.statusCode}');
        }
      } catch (e) {
        // If there is an error in sending the request
        print('Error sending POST request: $e');
      }

      // Delay to prevent flooding the server with requests
      await Future.delayed(const Duration(milliseconds: 200));
    }
    // When stopped, send 0
    await http.post(
      Uri.parse('http://192.168.8.150/message'),
      headers: {'Content-Type': 'text/plain'},
      body: '0',
    );
    print('Sent 0 when button released.');
  }

  void _stopPrinting(String direction) {
    setState(() {
      buttonState[direction] = false;
    });

    isPressed = false;
  }


  Widget _buildArrowButton({
    required String direction,
    required IconData icon,
    required VoidCallback onPressed,
    VoidCallback? onReleased,
  }) {
    return GestureDetector(
      onTapDown: (_) => onPressed(),
      onTapUp: (_) => onReleased?.call(),
      onTapCancel: onReleased,
      child: Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: buttonState[direction]!
                ? [Colors.greenAccent, Colors.green]
                : [Colors.green, Colors.lightGreenAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            size: 50,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: 'Page 1'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Up Button
            _buildArrowButton(
              direction: "up",
              icon: Icons.arrow_upward,
              onPressed: () => _printContinuously("up", 1),
              onReleased: () => _stopPrinting("up"),
            ),
            const SizedBox(height: 40), // Gap between rows
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Left Button
                _buildArrowButton(
                  direction: "left",
                  icon: Icons.arrow_back,
                  onPressed: () => _printContinuously("left", 4),
                  onReleased: () => _stopPrinting("left"),
                ),
                const SizedBox(width: 60), // Gap between buttons
                // Right Button
                _buildArrowButton(
                  direction: "right",
                  icon: Icons.arrow_forward,
                  onPressed: () => _printContinuously("right", 2),
                  onReleased: () => _stopPrinting("right"),
                ),
              ],
            ),
            const SizedBox(height: 40), // Gap between rows
            // Down Button
            _buildArrowButton(
              direction: "down",
              icon: Icons.arrow_downward,
              onPressed: () => _printContinuously("down", 3),
              onReleased: () => _stopPrinting("down"),
            ),
          ],
        ),
      ),
    );
  }
}
