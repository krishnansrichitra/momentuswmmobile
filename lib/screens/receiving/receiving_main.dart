import 'package:flutter/material.dart';

class ReceivingPage extends StatelessWidget {
  const ReceivingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Receiving"),
      ),
      body: const Center(
        child: Text("Receiving Screen"),
      ),
    );
  }
}