
import 'package:flutter/material.dart';
import '../../common/models/field_dto.dart';
import '../../common/builders/widget_builder.dart';

class ReceivingScreen extends StatefulWidget {
  final ScreenDto screenDto;

  const ReceivingScreen({
    super.key,
    required this.screenDto,
  });


  @override
  State<ReceivingScreen> createState() => _ReceivingScreenState();
}

class _ReceivingScreenState extends State<ReceivingScreen> {

  final Map<String, TextEditingController> controllers = {};

  void submit() {
    Map<String, dynamic> request = {};

    for (var field in widget.screenDto.fields ?? []) {
      request[field.accessor] =
          controllers[field.accessor]?.text;
    }

    print(request);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Receiving"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...(widget.screenDto.fields??[]).map((field) => buildField(field,controllers)),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: submit,
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}