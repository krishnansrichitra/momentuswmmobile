import '../models/field_dto.dart';
import 'package:flutter/material.dart';


  Widget buildField(FieldDto field,
      Map<String, TextEditingController> controllers) {
    if (field.type == "data_type_str") {
      controllers.putIfAbsent(
        field.accessor,
            () => TextEditingController(),
      );

      return TextField(
        controller: controllers[field.accessor],
        decoration: InputDecoration(
          labelText: field.label,
        ),
      );
    }

    if (field.type == "number") {
      controllers.putIfAbsent(
        field.accessor,
            () => TextEditingController(),
      );

      return TextField(
        controller: controllers[field.accessor],
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: field.label,
        ),
      );
    }

    return const SizedBox.shrink();
  }
