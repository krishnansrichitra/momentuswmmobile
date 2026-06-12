import '../../common/models/field_dto.dart';

class ReceivingScreenDto {
  final ScreenDto mobileScreenDTO;
  final String screenNo;
  String template;

  ReceivingScreenDto( {required this.mobileScreenDTO, required this.screenNo,required this.template });

  factory ReceivingScreenDto.fromJson(Map<String, dynamic> json) {
    return  ReceivingScreenDto(
        mobileScreenDTO: json['mobileScreenDTO'],
        screenNo: json['screenNo'],
      template: json['template']
    );
  }
}