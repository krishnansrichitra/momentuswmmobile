import '../../common/models/field_dto.dart';

class ReceivingScreenDto {
  final ScreenDto mobileScreenDTO;
  final int screenNo;
  String template;
  String? receivingId;
  bool? scanSuccess;
  String? errorMessage;
  String? infoMessage;
  bool? warning;
  String? buttonCode;
  ReceivingScreenDto( {required this.mobileScreenDTO, required this.screenNo,required this.template,  this.receivingId, this.scanSuccess , this.errorMessage,this.infoMessage,this.warning, this.buttonCode });

  factory ReceivingScreenDto.fromJson(Map<String, dynamic> json) {
    return  ReceivingScreenDto(
        mobileScreenDTO: ScreenDto.fromJson(
            json['mobileScreenDTO']),
        screenNo: json['screenNo'],
      template: json['template'],

      receivingId: json['receivingId'],
      scanSuccess: json['scanSuccess'],
      errorMessage: json['errorMessage'],
      infoMessage: json['infoMessage'],
      warning: json['warning'],
      buttonCode: json['buttonCode']

    );
  }
}