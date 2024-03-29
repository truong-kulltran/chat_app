import 'package:chat_app/routes.dart';
import 'package:chat_app/theme.dart';
import 'package:chat_app/utilities/app_constants.dart';
import 'package:chat_app/utilities/shared_preferences_storage.dart';
import 'package:chat_app/utilities/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/primary_button.dart';
import '../widgets/text_edit_dialog_widget.dart';

void showLoading(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
        ),
      );
    },
  );
}

void logout(BuildContext? context) async {
  SharedPreferencesStorage().resetDataWhenLogout();
  if (context != null) {
    Navigator.pushNamedAndRemoveUntil(
        context, AppRoutes.login, (route) => false);
  }
}

void logoutIfNeed(BuildContext? context) async {
  final passwordExpiredTime =
      SharedPreferencesStorage().getRefreshTokenExpired();
  if (passwordExpiredTime.isEmpty) {
    logout(context);
  } else {
    try {
      DateTime expiredDate = DateTime.parse(passwordExpiredTime);
      if (expiredDate.isBefore(DateTime.now())) {
        logout(context);
      }
    } catch (error) {
      logout(context);
    }
  }
}

clearFocus(BuildContext context) {
  if (FocusScope.of(context).hasFocus) {
    FocusScope.of(context).unfocus();
  } else {
    FocusScope.of(context).requestFocus(FocusNode());
  }
}

// AndroidAuthMessages androidLocalAuthMessage(//BuildContext context,
//         ) =>
//     const AndroidAuthMessages(
//       cancelButton: 'OK',
//       goToSettingsButton: 'Setting',
//       goToSettingsDescription:
//           'Biometrics is not set up on your device. Please either enable TouchId or FaceId on your phone.',
//     );
//
// IOSAuthMessages iosLocalAuthMessages(//BuildContext context,
//         ) =>
//     const IOSAuthMessages(
//       cancelButton: 'OK',
//       goToSettingsButton: 'Setting',
//       goToSettingsDescription:
//           'Biometrics is not set up on your device. Please either enable TouchId or FaceId on your phone.',
//     );

Future<void> showMessageNoInternetDialog(
  BuildContext context, {
  Function()? onClose,
  String? buttonLabel,
}) async {
  await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text(
            AppConstants.noInternetTitle,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Image.asset(
                  'assets/images/ic_no_internet.png',
                  height: 150,
                  width: 150,
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 16),
                alignment: Alignment.center,
                child: const Text(
                  AppConstants.noInternetContent,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
                if (onClose != null) {
                  onClose();
                }
              },
              child: Text(buttonLabel ?? 'OK'),
            ),
          ],
        );
      });
}

Future<void> showCupertinoMessageDialog(
  BuildContext context,
  String? title, {
  String? content,
  Function()? onClose,
  String? buttonLabel,

  /// false = user must tap button, true = tap outside dialog
  bool barrierDismiss = false,
}) async {
  await showCupertinoDialog(
    barrierDismissible: barrierDismiss,
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: title == null ? null : Text(title),
        content: content == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(content),
              ),
        actions: <Widget>[
          CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
                if (onClose != null) {
                  onClose();
                }
              },
              child: Text(buttonLabel ?? 'OK')),
        ],
      );
    },
  );
}

Future<void> showMessageTwoOption(
  BuildContext context,
  String? title, {
  String? content,
  Function()? onCancel,
  String? cancelLabel,
  Function()? onOk,
  String? okLabel,

  /// false = user must tap button, true = tap outside dialog
  bool barrierDismiss = false,
}) async {
  await showCupertinoDialog(
    barrierDismissible: barrierDismiss,
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: title == null ? null : Text(title),
        content: content == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(content),
              ),
        actions: <Widget>[
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context);
              if (onCancel != null) {
                onCancel();
              }
            },
            child: Text(cancelLabel ?? 'Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context);
              if (onOk != null) {
                onOk();
              }
            },
            child: Text(
              okLabel ?? 'OK',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );
}

Future<void> showSuccessBottomSheet(
  BuildContext context, {
  bool isDismissible = false,
  bool enableDrag = false,
  String? titleMessage,
  String? contentMessage,
  String? buttonLabel,
  required Function() onTap,
}) async {
  await showModalBottomSheet(
    context: context,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    builder: (context) => WillPopScope(
      onWillPop: () async {
        return isDismissible;
      },
      child: Container(
        height: 350,
        color: AppColors.grey630,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(35),
              topRight: Radius.circular(35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Icon(
                        Icons.verified_outlined,
                        size: 150,
                        color: AppColors.green600,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        titleMessage ?? 'Successfully!',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                      width: 300,
                      child: Text(
                        contentMessage ?? '',
                        //maxLines: 3,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: PrimaryButton(
                  text: buttonLabel,
                  onTap: onTap,
                ),
              )
            ],
          ),
        ),
      ),
    ),
  );
}

Future<String?> showTextDialog<T>(
  BuildContext context, {
  required String title,
  required String value,
}) =>
    showDialog<String>(
      context: context,
      builder: (context) => TextDialogWidget(
        title: title,
        value: value,
      ),
    );

Future<String?> pickImage(BuildContext context) async {
  String? imagePath;
  showCupertinoModalPopup(
    context: context,
    builder: (context) {
      return CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              imagePath = await pickPhoto(ImageSource.camera);
            },
            child: Text(
              'Take a photo from camera',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              imagePath = await pickPhoto(ImageSource.gallery);
            },
            child: Text(
              'Choose a photo from gallery',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Cancel',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black.withOpacity(0.7),
            ),
          ),
        ),
      );
    },
  );
  return imagePath;
}
