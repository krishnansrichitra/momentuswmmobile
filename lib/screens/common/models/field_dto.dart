class FieldDto {
  final int sequence;
  final String? label;
  final String? type;
  final String? accessor;
  final String? populator;
  final String? value;
  final bool? mandatory;

  FieldDto( {required this.sequence,required this.label, required this.type,  required this.accessor, required this.populator,
    required this.value,  required this.mandatory});

  factory FieldDto.fromJson(Map<String, dynamic> json) {
    return FieldDto(
    sequence: json['sequence'],
    label: json['label'],
    type : json['type'],
    accessor : json['accessor'],
    populator : json['populator'],
    value : json['value'],
    mandatory : json['mandatory']
    );
  }

}

class ButtonDto {
  final int sequence;
  final String? label;
  final String? action;

  ButtonDto( { required this.sequence,  this.label,  this.action });

  factory ButtonDto.fromJson(Map<String, dynamic> json) {
  return ButtonDto ( sequence : json['sequence'],
        label : json['label'],
      action : json['action']  );
  }


}
class ScreenDto {
  final List<FieldDto>? fields;
  final List<ButtonDto>? buttons;

  ScreenDto( { this.fields, this.buttons} ) ;

  factory ScreenDto.fromJson(Map<String, dynamic> json) {
     return  ScreenDto (
         fields: (json['fields'] as List).map((e) => FieldDto.fromJson(e)).toList(),
         buttons: (json['buttons'] as List).map((e) => ButtonDto.fromJson(e)).toList(),
     );
  }




}