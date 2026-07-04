import '../models/field_dto.dart';
import 'package:flutter/material.dart';
import 'scanner_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String?> openScanner(BuildContext context) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ScannerScreen()),
  );

  return result;
}

Future<List<Map<String, String>>> loadOptions(String popu) async {
  final prefs = await SharedPreferences.getInstance();
  final jwt = prefs.getString("jwt");
  final uri = Uri.parse(
    "${AppConfig.apiBaseUrl}/wms/api/mobile/dropdown?populator=" + popu,
  );
  final response = await http.get(
    uri,
    headers: {
      "Authorization": "Bearer $jwt",
      "Content-Type": "application/json",
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> jsonList = jsonDecode(response.body);

    return jsonList.map((e) {
      return {
        "code": e["code"].toString(),
        "description": e["description"].toString(),
      };
    }).toList();
  }

  throw Exception("Failed to load dropdown options");
}


void showError(BuildContext context, String? message) {
  if (message == null || message.trim().isEmpty) {
    return;
  }

  ScaffoldMessenger.of(context).clearSnackBars();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 3),
    ),
  );
}

Widget buildField(
  BuildContext context,
  FieldDto field,
  Map<String, dynamic> controllers,
  Map<String, dynamic> formValues,
    Future<void> Function(FieldDto, String) callback
) {
  if (field.type == "data_type_str") {
    String? selectedValue;
    if (field.populator != null && field.populator != '') {
      return FutureBuilder<List<Map<String, String>>>(
        future: loadOptions(field.populator!),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          final options = snapshot.data!;
          return DropdownButtonFormField<String>(
            initialValue: selectedValue,
            onChanged: (value) {
              formValues[field.accessor] = value;
            },
            decoration: InputDecoration(
              labelText: field.mandatory ?? false
                  ? "${field.label} *"
                  : field.label,
            ),
            items: options.map((item) {
              return DropdownMenuItem<String>(
                value: item["code"],
                child: Text(item["description"]!),
              );
            }).toList(),
          );
        },
      );
    }

    controllers.putIfAbsent(
      field.accessor!,
          () => TextEditingController(text: field.value ?? ''),
    );
    if (field.scannable == true) {
      return TextFormField(
        controller: controllers[field.accessor],
        onFieldSubmitted: (value) async {
          await callback(field, value);
        },
        decoration: InputDecoration(
          labelText: field.label,
          suffixIcon: IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () async {
              final scannedValue = await openScanner(context);
              if (scannedValue != null) {
                controllers[field.accessor]!.text = scannedValue;
              }
            },
          ),
        ),
      );
    } else {
      return TextFormField(
        controller: controllers[field.accessor],
        decoration: InputDecoration(
          labelText: field.mandatory ?? false
              ? "${field.label} *"
              : field.label,
        ),
        validator: (value) {
          if ((field.mandatory ?? false) &&
              (value == null || value.trim().isEmpty)) {
            return "${field.label} is required";
          }
          return null;
        },
      );
    }
  }

  if (field.type == "data_type_long") {
    controllers.putIfAbsent(
      field.accessor!,
          () => TextEditingController(text: field.value ?? ''),
    );

    return TextFormField(
      controller: controllers[field.accessor],
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: field.mandatory ?? false ? "${field.label} *" : field.label,
      ),
      validator: (value) {
        if ((field.mandatory ?? false) &&
            (value == null || value.trim().isEmpty)) {
          return "${field.label} is required";
        }
        return null;
      },
    );
  }

  if (field.type == "data_type_date") {
    controllers.putIfAbsent(field.accessor, () => TextEditingController());

    return TextFormField(
      controller: controllers[field.accessor],
      readOnly: true,
      decoration: InputDecoration(
        labelText: (field.mandatory ?? false)
            ? "${field.label} *"
            : field.label,
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );

        if (pickedDate != null) {
          controllers[field.accessor]!.text =
              "${pickedDate.year}-"
              "${pickedDate.month.toString().padLeft(2, '0')}-"
              "${pickedDate.day.toString().padLeft(2, '0')}";
        }
      },
      validator: (_) {
        final text = controllers[field.accessor]?.text ?? "";

        if ((field.mandatory ?? false) && text.trim().isEmpty) {
          return "${field.label} is required";
        }

        return null;
      },
    );
  }
  return const SizedBox.shrink();
}
