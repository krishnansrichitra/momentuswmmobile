import 'package:flutter/material.dart';
import '../../common/models/field_dto.dart';
import '../../common/builders/widget_builder.dart';
import '../receiving_main.dart';
import '../../../app_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/receiving_screen_dto.dart';
import '../../../main.dart';

class ReceivingScreen extends StatefulWidget {
  final ScreenDto screenDto;
  final int screenNo;
  final String template;
  final String? receivingId;
  final bool? scanSuccess;
  final String? errorMessage;
  final String? infoMessage;
  final bool? warning;
  final String? buttonCode;

  const ReceivingScreen({
    super.key,
    required this.screenDto,
    required this.screenNo,
    required this.template,
    required this.receivingId,
    required this.scanSuccess,
    required this.errorMessage,
    required this.infoMessage,
    required this.warning,
    required this.buttonCode

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
      if (result.scanSuccess == true) {
        if (result.screenNo == 100 ) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
        }else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ReceivingScreen(
                    screenDto: result.mobileScreenDTO,
                    screenNo: result.screenNo,
                    template: result.template,
                    receivingId: result.receivingId,
                    scanSuccess: result.scanSuccess,
                    errorMessage: result.errorMessage,
                    infoMessage: result.infoMessage,
                    warning: result.warning,
                    buttonCode: result.buttonCode
                  ),
            ),
          );
        }
      }else {
        showError(context, result.errorMessage);
      }
    }
  }

  Future<void> scanAndPush(Map<String, dynamic> request,String action,String accessor,String barcode) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("jwt");
    if (widget.screenDto.fields?.length == 1) {
      request['receivingId'] = widget.receivingId;
      final uri =
      Uri.parse(
        "${AppConfig.apiBaseUrl}/wms/api/rcvcontroller/scanBarcode",
      ).replace(
        queryParameters: {
          "template": widget.template,
          "screenNo": widget.screenNo.toString(),
          "action": action,
          "accessor": accessor,
          "barcode": barcode
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
      print(response);
      if (response.statusCode == 200) {
        ReceivingScreenDto result = ReceivingScreenDto.fromJson(
          jsonDecode(response.body),
        );
        print(result);
        if (result.scanSuccess == true) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ReceivingScreen(
                    screenDto: result.mobileScreenDTO,
                    screenNo: result.screenNo,
                    template: result.template,
                    receivingId: result.receivingId,
                    scanSuccess: result.scanSuccess,
                    errorMessage: result.errorMessage,
                    infoMessage: result.infoMessage,
                    warning: result.warning,
                    buttonCode: result.buttonCode,
                  ),
            ),
          );
        } else {
          showError(context, result.errorMessage);
        }
      }
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


  Future<void> scanCompleted(
      FieldDto field,
      String value) async {
    print("Scanned: $value");
    Map<String, dynamic> request = {};
    scanAndPush(request, "defaultAction", field.accessor, value);

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


  void startReceiving ()
  {
    submit('START_REC');
  }

  void receiviePallet ()
  {
    submit('REC_PALLET');
  }

  void receivieCases ()
  {
    submit('REC_CASE');
  }

  void receiveItems ()
  {
    submit('REC_ITEM');
  }

  void verifyCases ()
  {
    submit('VERIFY_CASES');
  }

  void verifyItems ()
  {
    submit('VERIFY_ITEMS');
  }


  void scanPallet ()
  {
    submit('SCAN_PALLET');
  }

  void scanCase ()
  {
    submit('SCAN_CASE');
  }


  void scanComplete ()
  {
    submit('SCAN_COMPLETE');
  }

  void capturePic ()
  {
    submit('CAPTURE_PIC');
  }

  void completeReceiving()
  {
    submit('COMPLETE_REC');
  }

  void defaultSubmit()
  {
    submit('DefaultAction');

  }

  List<Widget> buildButtons() {
    List<Widget> buttons = [];

    if (widget.buttonCode?.contains("A") ?? false) {
      buttons.add(
        ElevatedButton(
          onPressed: startReceiving,
          child: const Text("Start Receiving"),
        ),
      );
    }

    if (widget.buttonCode?.contains("B") ?? false) {
      buttons.add(
        ElevatedButton(
          onPressed: receiviePallet,
          child: const Text("Receive Pallet"),
        ),
      );
    }
    if (widget.buttonCode?.contains("C") ?? false) {
      buttons.add(
        ElevatedButton(
          onPressed: receivieCases,
          child: const Text("Receive Cases"),
        ),
      );
    }
    if (widget.buttonCode?.contains("D") ?? false) {
      buttons.add(
        ElevatedButton(
          onPressed: receiveItems,
          child: const Text("Receive Items"),
        ),
      );
    }

    if (widget.buttonCode?.contains("E") ?? false) {
      buttons.add(
        ElevatedButton(
          onPressed: verifyCases,
          child: const Text("Verify Cases"),
        ),
      );
    }

    if (widget.buttonCode?.contains("F") ?? false) {
      buttons.add(
        ElevatedButton(
          onPressed: verifyItems,
          child: const Text("Verify Items"),
        ),
      );
    }
    if (widget.buttonCode?.contains("G") ?? false) {
      buttons.add(
        ElevatedButton(
          onPressed: scanPallet,
          child: const Text("Scan Pallet"),
        ),
      );
    }

    if (widget.buttonCode?.contains("H") ?? false) {
      buttons.add(
        ElevatedButton(
          onPressed: scanCase,
          child: const Text("Scan Case"),
        ),
      );
    }

    if (widget.buttonCode?.contains("I") ?? false) {
      buttons.add(
        ElevatedButton(
          onPressed: scanComplete,
          child: const Text("Scan Complete"),
        ),
      );
    }
    if (widget.buttonCode?.contains("J") ?? false) {
      buttons.add(
        ElevatedButton(
          onPressed: capturePic,
          child: const Text("Capture Pic"),
        ),
      );
    }
    if (widget.buttonCode?.contains("K") ?? false) {
      buttons.add(
        ElevatedButton(
          onPressed: completeReceiving,
          child: const Text("Complete Receiving"),
        ),
      );
    }
    return buttons;
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
              if (widget.infoMessage != null && widget.infoMessage!.isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.infoMessage!,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ...(widget.screenDto.fields ?? []).map(
                (field) => buildField(context,field, controllers,formValues,scanCompleted),
              ),

              const SizedBox(height: 20),
              Row(
                children: [
                  if (widget.screenNo == 1)...buildButtons()
                  else if (widget.screenNo == 2)... buildButtons()
                  else if (widget.screenNo == 3)... buildButtons()
                  else ...buildButtons()
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
