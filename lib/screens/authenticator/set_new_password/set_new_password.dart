import 'package:chat_app/network/repository/auth_repository.dart';
import 'package:chat_app/screens/authenticator/login/login_bloc.dart';
import 'package:chat_app/screens/authenticator/login/login_page.dart';
import 'package:chat_app/screens/authenticator/set_new_password/set_new_password_bloc.dart';
import 'package:chat_app/screens/authenticator/set_new_password/set_new_password_event.dart';
import 'package:chat_app/screens/authenticator/set_new_password/set_new_password_state.dart';
import 'package:chat_app/utilities/enum/api_error_result.dart';
import 'package:chat_app/utilities/screen_utilities.dart';
import 'package:chat_app/widgets/animation_loading.dart';
import 'package:chat_app/widgets/input_password_field.dart';
import 'package:chat_app/widgets/primary_button.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SetNewPassword extends StatefulWidget {
  final String email;

  const SetNewPassword({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  State<SetNewPassword> createState() => _SetNewPasswordState();
}

class _SetNewPasswordState extends State<SetNewPassword> {
  final focusNode = FocusNode();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isShowPassword = false;
  bool _isShowRePassword = false;

  //for validate password
  String messageValidate = '';
  bool hasCharacter = false;
  bool checkValidatePassword = false;

  late SetNewPasswordBloc _newPasswordBloc;

  final AuthRepository _authRepository = AuthRepository();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _newPasswordBloc = BlocProvider.of<SetNewPasswordBloc>(context);
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _newPasswordBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: BlocConsumer<SetNewPasswordBloc, SetNewPasswordState>(
        listenWhen: (previousState, currentState) {
          return currentState.apiError != ApiError.noError;
        },
        listener: (context, state) {
          if (state.apiError == ApiError.internalServerError) {
            showCupertinoMessageDialog(
              context,
              'error',
              content: 'internal_server_error',
            );
          }
          if (state.apiError == ApiError.noInternetConnection) {
            showCupertinoMessageDialog(
              context,
              'error',
              content: 'no_internet_connection',
            );
          }
        },
        builder: (context, state) {
          Widget body = const SizedBox.shrink();
          if (state.isLoading) {
            body = const Scaffold(body: AnimationLoading());
          } else {
            body = _body(state);
          }
          return body;
        },
      ),
    );
  }

  Widget _body(SetNewPasswordState state) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).primaryColor,
          centerTitle: true,
          title: const Text(
            'Set a new password',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                      child: Image.asset(
                        'assets/images/app_logo_light.png',
                        height: 200,
                        width: 200,
                      ),
                    ),
                    _inputPasswordField(
                      labelText: 'New password',
                      hintText: 'Enter your new password',
                      controller: _passwordController,
                      obscureText: !_isShowPassword,
                      onTapSuffixIcon: () {
                        setState(() {
                          _isShowPassword = !_isShowPassword;
                        });
                      },
                      onSubmitted: (_) {},
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter new password';
                        }
                        if (value.isNotEmpty && value.length < 6) {
                          return 'New password  must be at least 6 characters';
                        } else if (value.length > 40) {
                          return 'New password must be less than 40 characters';
                        }
                        return null;
                      },
                    ),
                    _inputPasswordField(
                      labelText: 'Confirm new password',
                      hintText: 'Re-enter your new password',
                      controller: _confirmPasswordController,
                      obscureText: !_isShowRePassword,
                      onTapSuffixIcon: () {
                        setState(() {
                          _isShowRePassword = !_isShowRePassword;
                        });
                      },
                      onSubmitted: (_) {},
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter confirm new password';
                        } else if (value.length < 6) {
                          return 'Confirm new password must be at least 6 characters';
                        } else if (value.length > 40) {
                          return 'Confirm new password must be less than 40 characters';
                        } else if (value != _passwordController.text) {
                          return 'New password and confirm new password do not match';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              _buttonVerify(state)
            ],
          ),
        ),
      ),
    );
  }

  _buttonVerify(SetNewPasswordState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: PrimaryButton(
        text: 'Set a password',
        onTap: () async {
          if (_formKey.currentState!.validate()) {
            await _handleButton();
          }
        },
      ),
    );
  }

  Future<void> _handleButton() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none && mounted) {
      showMessageNoInternetDialog(context);
    } else {
      _newPasswordBloc.add(DisplayLoading());
      final response = await _authRepository.newPassword(
        email: widget.email,
        password: _passwordController.text.trim(),
        confirmPassword: _confirmPasswordController.text.trim(),
      );

      if (response.isOK() && mounted) {
        _newPasswordBloc.add(OnSuccess());
        showSuccessBottomSheet(
          context,
          enableDrag: false,
          isDismissible: false,
          // titleMessage: 'Successfully!',
          contentMessage: '${response.message}',
          buttonLabel: 'Login',
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider<LoginBloc>(
                  create: (context) => LoginBloc(context),
                  child: const LoginPage(),
                ),
              ),
            );
          },
        );
      } else {
        showCupertinoMessageDialog(
          context,
          "Error!",
          // content: response.errors?.first.errorMessage,
          content: 'Set new password failure',
        );
      }
    }
  }

  Widget _inputPasswordField({
    String? labelText,
    String? hintText,
    required TextEditingController controller,
    Function()? onTapSuffixIcon,
    bool obscureText = false,
    String? Function(String?)? validator,
    Function(String?)? onSubmitted,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 16),
      child: InputPasswordField(
        obscureText: obscureText,
        onTapSuffixIcon: onTapSuffixIcon,
        keyboardType: TextInputType.text,
        controller: controller,
        onChanged: (text) {},
        validator: validator,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: onSubmitted,
        hint: hintText,
        prefixIcon: Icons.lock_outline,
        labelText: labelText,
      ),
    );
  }
}
