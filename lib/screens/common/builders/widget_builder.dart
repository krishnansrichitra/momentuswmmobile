import '../models/field_dto.dart';
import 'package:flutter/material.dart';


  Widget buildField(  BuildContext context,
      FieldDto field,
      Map<String, TextEditingController> controllers) {
    if (field.type == "data_type_str") {
      controllers.putIfAbsent(
        field.accessor,
            () => TextEditingController(),
      );

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
