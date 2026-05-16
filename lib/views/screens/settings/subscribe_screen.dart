import 'package:flutter/material.dart';

class SubscribeScreen extends StatelessWidget {
  const SubscribeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Subscribe"),
      ),
      body: const Center(
        child: Text("Subscribe Screen"),
      ),
    );
  }
}