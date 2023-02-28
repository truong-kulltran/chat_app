import 'package:chat_app/screens/authenticator/login/login_event.dart';
import 'package:chat_app/screens/authenticator/login/login_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';

import '../../../utilities/enum/biometrics_button_type.dart';
import '../../../utilities/enum/highlight_status.dart';
import '../../../utilities/screen_utilities.dart';

class LoginBloc extends Bloc<LoginEvent, AuthenticationState> {
  LoginBloc() : super(CheckAuthenticateInProgress()) {
    on((event, emit) async {
      if (event is CheckAuthenticationStarted) {
        emit(
          CheckAuthenticateInProgress(),
        );
      }
      if (event is CheckAuthenticationFailed) {
        emit(
          NotLogin(
            isShowLoginBiometrics: event.isShowBiometrics,
          ),
        );
      }
    });
  }
}

class LoginFormBloc extends Bloc<LoginFormEvent, LoginFormState> {
  final BuildContext context;

  LoginFormBloc(this.context) : super(LoginFormState()) {
    on((event, emit) async {
      if (event is ValidateForm) {
        emit(
          state.copyWith(
            isEnable: event.isValidate,
            isAuthenticating: false,
          ),
        );
      }

      if (event is DisplayLoading) {
        emit(
          state.copyWith(
            isAuthenticating: true,
          ),
        );
      }

      if(event is LoginWithBiometrics){
        final LocalAuthentication auth = LocalAuthentication();
        final bool canAuthenticate =
            await auth.canCheckBiometrics || await auth.isDeviceSupported();
        if (canAuthenticate) {
          var buttonType = await getBiometricButtonType();
          try {
            emit(
              state.copyWith(
                buttonStatus: HighlightStatus.active,
                biometricButtonType: buttonType,
                isSuccessAuthenticateBiometric: false,
                isAuthenticating: false,
              ),
            );

            final result = await auth.authenticate(
              localizedReason:'',
              options: const AuthenticationOptions(biometricOnly: true),
              authMessages: <AuthMessages>[
                androidLocalAuthMessage(),
                iosLocalAuthMessages(),
              ],
            );

            emit(
              state.copyWith(
                buttonStatus: HighlightStatus.inActive,
                biometricButtonType: buttonType,
                isSuccessAuthenticateBiometric: result,
              ),
            );
          } on PlatformException catch (e) {
            emit(
              state.copyWith(
                buttonStatus: HighlightStatus.inActive,
                biometricButtonType: buttonType,
                errorMessage: e.code,
                isAuthenticating: false,
              ),
            );
          }
        } else {
          emit(
            state.copyWith(
              buttonStatus: HighlightStatus.notAvailable,
              isAuthenticating: false,
            ),
          );
        }
      }
    });
  }

  Future<BiometricButtonType> getBiometricButtonType() async {
    final availableBiometrics =
    await LocalAuthentication().getAvailableBiometrics();
    if (availableBiometrics.length == 1) {
      if (availableBiometrics.contains(BiometricType.face)) {
        return BiometricButtonType.face;
      }
      if (availableBiometrics.contains(BiometricType.fingerprint)) {
        return BiometricButtonType.touch;
      }
    }
    return BiometricButtonType.faceAndTouch;
  }
}
