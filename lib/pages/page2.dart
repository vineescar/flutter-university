import 'package:flutter/material.dart';
import '../common_app_bar.dart';

class Page2 extends StatelessWidget {
  const Page2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: 'Page 2'),
      body: const Center(
        child: Text('This is Page 2'),
      ),
    );
  }
}
