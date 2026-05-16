import 'package:flutter/material.dart';

class RateScreen extends StatelessWidget {
  const RateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("RateApp"),
      ),
      body: const Center(
        child: Text("Rate App Now"),
      ),
    );
  }
}