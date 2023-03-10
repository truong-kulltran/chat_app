import 'package:chat_app/network/provider/provider_mixin.dart';
import 'package:chat_app/network/response/base_response.dart';
import 'package:dio/dio.dart';

import '../api/api_path.dart';
import '../response/sign_up_response.dart';

class SignUpProvider with ProviderMixin {
  Future<BaseResponse> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final data = {
        "email": email,
        "password": password,
        "username": username,
      };
      final response = await dio.post(
        ApiPath.signup,
        data: data,
        options: Options(
          sendTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
          receiveDataWhenStatusError: true,
        ),
      );

      return SignUpResponse.fromJson(response.data);
    } catch (error, stacktrace) {
      return errorResponse(error, stacktrace, ApiPath.signup);
    }
  }
}
