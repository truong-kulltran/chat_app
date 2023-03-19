import 'package:chat_app/network/response/base_response.dart';
import 'package:chat_app/network/response/error_response.dart';

class ForgotPasswordResponse extends BaseResponse {
  final String? message;
  ForgotPasswordResponse({
    this.message,
    int? httpStatus,
    List<Errors>? errors,
  }) : super(httpStatus: httpStatus, errors: errors);
  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) =>
      ForgotPasswordResponse(
        httpStatus: json["httpStatus"],
        errors: json["errors"],
        message: json['message'],
      );

  @override
  String toString() {
    return 'ForgotPasswordResponse{message: $message, error: $errors}';
  }
}