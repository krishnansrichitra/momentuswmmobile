import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_config.dart';
import 'receiving_apis.dart';
import 'models/receiving_screen_dto.dart';
import 'controller/receiving_controller.dart';

class ReceivingPage extends StatefulWidget {
  const ReceivingPage({super.key});

  @override
  State<ReceivingPage> createState() => _ReceivingPageState();
}

class _ReceivingPageState extends State<ReceivingPage> {
  bool loading = true;
  String message = "";
  List<String> options = [];

  @override
  void initState() {
    super.initState();
    loadReceivingOptions();
  }

  Future<void> loadReceivingOptions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwt");

      if (token == null || token.isEmpty) {
        setState(() {
          loading = false;
          message = "Token not found. Please login again.";
        });
        return;
      }

      final response = await http.get(
        Uri.parse("${AppConfig.apiBaseUrl}/wms/api/rcvTemplate/allTemplates"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          options = data.map((e) => e.toString()).toList();
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
          message = "API failed: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
        message = "Error calling API: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      appBar: AppBar(
        title: const Text("Receiving"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : message.isNotEmpty
          ? Center(child: Text(message))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: options.length,
        itemBuilder: (context, index) {
          final option = options[index];

          return Card(
            child: ListTile(
              title: Text(option),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () async {
                print("Selected: $option");
                ReceivingScreenDto result =
                    await ReceivingApiService.getInitScreen(option);
                print(result.screenNo);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReceivingScreen(
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
              },
            ),
          );
        },
      ),
    );
  }
}