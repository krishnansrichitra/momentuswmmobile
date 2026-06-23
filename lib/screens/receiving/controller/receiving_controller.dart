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
  final int? receivingId;

  const ReceivingScreen({
    super.key,
    required this.screenDto,
    required this.screenNo,
    required this.template,
    required this.receivingId
  });

  @override
  State<ReceivingScreen> createState() => _ReceivingScreenState();
}

class _ReceivingScreenState extends State<ReceivingScreen> {
  final Map<String, TextEditingController> controllers = {};
  final Map<String, dynamic> formValues = {};
  final _formKey = GlobalKey<FormState>();

  Future<void> loadNextScreen(Map<String, dynamic> request,String action) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("jwt");
    request['receivingId'] = widget.receivingId;
    final uri =
        Uri.parse(
          "${AppConfig.apiBaseUrl}/wms/api/rcvcontroller/submitreceiving",
        ).replace(
          queryParameters: {
            "template": widget.template,
            "screenNo": widget.screenNo.toString(),
            "action": action,
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
            receivingId: result.receivingId,
          ),
        ),
      );
    }
  }

  void complete()
  {
    Map<String, dynamic> request = {};
    if (!_formKey.currentState!.validate()) {
      return;
    }

    for (var field in widget.screenDto.fields ?? []) {
      request[field.accessor] =
          controllers[field.accessor]?.text ??
              formValues[field.accessor];
    }
    print(request);
  }

  void submit(String action) {
    Map<String, dynamic> request = {};
    if (!_formKey.currentState!.validate()) {
      return;
    }

    for (var field in widget.screenDto.fields ?? []) {
      request[field.accessor] =
          controllers[field.accessor]?.text ??
              formValues[field.accessor];
    }
    print(request);
    loadNextScreen(request,action);
  }

  void previous() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReceivingPage()),
    );
  }

  void scanLPN ()
  {
    submit('scanLPN');
  }

  void scanChildLPN ()
  {
    submit('scanChildLPN');
  }

  void scanItem ()
  {
    submit('scanItem');
  }

  void generateLPN()
  {

    submit('generateLPNNo');
  }

  void completeScan()
  {
    submit('completeScan');
  }

  void completeReceiving()
  {
    submit('completeReceiving');
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
                (field) => buildField(context,field, controllers,formValues),
              ),

              const SizedBox(height: 20),
              Row(
                children: [
                  if (widget.screenNo == 1)...[
                    ElevatedButton(
                      onPressed: scanLPN,
                      child: const Text("Scan LPN"),
                    ),
                  const SizedBox(width: 20),
                 ]else if (widget.screenNo == 2)...[
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        ElevatedButton(
                          onPressed: scanItem,
                          child: const Text("Scan Item"),
                        ),
                        ElevatedButton(
                          onPressed: scanChildLPN,
                          child: const Text("Scan Child LPN"),
                        ),
                        ElevatedButton(
                          onPressed: generateLPN,
                          child: const Text("Generate LPN No"),
                        ),
                      ],
                    )
                  ]else if (widget.screenNo == 3)...[
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        ElevatedButton(
                          onPressed: scanItem,
                          child: const Text("Scan  Next Item"),
                        ),
                        ElevatedButton(
                          onPressed: scanLPN,
                          child: const Text("Scan Next LPN"),
                        ),
                        ElevatedButton(
                          onPressed: completeScan,
                          child: const Text("Generate LPN No"),
                        ),
                      ],
                    )
                  ]else
                    ElevatedButton(
                      onPressed: completeReceiving,
                      child: const Text("Proceed"),
                    ),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
