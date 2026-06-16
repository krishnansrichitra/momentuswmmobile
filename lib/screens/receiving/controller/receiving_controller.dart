import 'package:flutter/material.dart';
import '../../common/models/field_dto.dart';
import '../../common/builders/widget_builder.dart';
import '../receiving_main.dart';
import '../../../app_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/receiving_screen_dto.dart';

class ReceivingScreen extends StatefulWidget {
  final ScreenDto screenDto;
  final int screenNo;
  final String template;

  const ReceivingScreen({
    super.key,
    required this.screenDto,
    required this.screenNo,
    required this.template,
  });

  @override
  State<ReceivingScreen> createState() => _ReceivingScreenState();
}

class _ReceivingScreenState extends State<ReceivingScreen> {
  final Map<String, TextEditingController> controllers = {};
  final _formKey = GlobalKey<FormState>();

  Future<void> loadNextScreen(Map<String, dynamic> request) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("jwt");
    final uri =
        Uri.parse(
          "${AppConfig.apiBaseUrl}/wms/api/rcvcontroller/submitreceiving",
        ).replace(
          queryParameters: {
            "template": widget.template,
            "screenNo": widget.screenNo.toString(),
            "action": "next",
          },
        );
    final response = await http.post(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(request),
    );

    if (response.statusCode == 200) {
      ReceivingScreenDto result = ReceivingScreenDto.fromJson(
        jsonDecode(response.body),
      );
      print(result);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReceivingScreen(
            screenDto: result.mobileScreenDTO,
            screenNo: result.screenNo,
            template: result.template,
          ),
        ),
      );
    }
  }

  void submit() {
    Map<String, dynamic> request = {};
    if (!_formKey.currentState!.validate()) {
      return;
    }

    for (var field in widget.screenDto.fields ?? []) {
      request[field.accessor] = controllers[field.accessor]?.text;
    }
    print(request);
    loadNextScreen(request);
  }

  void previous() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReceivingPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Receiving")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ...(widget.screenDto.fields ?? []).map(
                (field) => buildField(context,field, controllers),
              ),

              const SizedBox(height: 20),
              Row(
                children: [
                  if (widget.screenNo == 1)
                    ElevatedButton(
                      onPressed: previous,
                      child: const Text("Previous"),
                    ),
                  const SizedBox(width: 20),
                  ElevatedButton(onPressed: submit, child: const Text("Next")),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
