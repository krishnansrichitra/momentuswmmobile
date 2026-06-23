import '../models/field_dto.dart';
import 'package:flutter/material.dart';
import 'scanner_screen.dart';

Future<String?> openScanner(BuildContext context) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const ScannerScreen(),
    ),
  );

  return result;
}

  Widget buildField(  BuildContext context,
      FieldDto field,
      Map<String, dynamic> controllers,
      Map<String, dynamic> formValues) {
    if (field.type == "data_type_str") {
      if (field.populator != null && field.populator != ''){
        String? selectedValue ;
        final List<Map<String, String>> options = [
          {
            "code": "PLT",
            "description": "Pallet",
          },
          {
            "code": "CSE",
            "description": "Case",
          },
        ];
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
      }
      controllers.putIfAbsent(
        field.accessor,
            () => TextEditingController(),
      );
      if (field.scannable == true ) {
        return TextFormField(
          controller: controllers[field.accessor],
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
      }else {
        return TextFormField(
          controller: controllers[field.accessor],
          decoration: InputDecoration(
            labelText: field.mandatory ?? false
                ? "${field.label} *"
                : field.label,
          ),
          validator: (value) {
            if ((field.mandatory ?? false) &&
                (value == null || value
                    .trim()
                    .isEmpty)) {
              return "${field.label} is required";
            }
            return null;
          },
        );
      }
    }

    if (field.type == "data_type_long") {
      controllers.putIfAbsent(
        field.accessor,
            () => TextEditingController(),
      );

      return TextFormField(
        controller: controllers[field.accessor],
        keyboardType: TextInputType.number,
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


    if (field.type == "data_type_date") {
      controllers.putIfAbsent(
        field.accessor,
            () => TextEditingController(),
      );

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
          final text =
              controllers[field.accessor]?.text ?? "";

          if ((field.mandatory ?? false) &&
              text.trim().isEmpty) {
            return "${field.label} is required";
          }

          return null;
        },
      );
    }
    return const SizedBox.shrink();
  }
