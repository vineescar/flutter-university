import 'package:flutter/material.dart';
import '../common_app_bar.dart';

class Page3 extends StatelessWidget {
  const Page3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: 'Page 3'),
      body: const Center(
        child: Text('This is Page 3'),
      ),
    );
  }
}
