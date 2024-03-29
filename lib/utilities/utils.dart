import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:chat_app/utilities/enum/biometrics_button_type.dart';
import 'package:chat_app/utilities/enum/media_type.dart';
import 'package:chat_app/utilities/enum/message_type.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

String getBiometricsButtonPath({
  BiometricButtonType? buttonType,
}) {
  if (buttonType == BiometricButtonType.face) {
    return 'assets/images/ic_face_id.png';
  }
  if (buttonType == BiometricButtonType.touch) {
    return 'assets/images/ic_touch_id.png';
  }
  return 'assets/images/ic_face_touch_id.png';
}

bool isNotNullOrEmpty(dynamic obj) => !isNullOrEmpty(obj);

/// For String, List, Map
bool isNullOrEmpty(dynamic obj) =>
    obj == null ||
    ((obj is String || obj is List || obj is Map) && obj.isEmpty);

Future<String> pickPhoto(ImageSource imageSource) async {
  final pickedFile = (imageSource == ImageSource.camera
      ? await ImagePicker().pickImage(
          source: ImageSource.camera,
          imageQuality: 50,
          maxWidth: 2048,
          maxHeight: 2048,
        )
      : await ImagePicker().pickImage(source: ImageSource.gallery));
  if (pickedFile == null) {
    return '';
  }
  File image = File(pickedFile.path);

  return image.path;
}

Future<String> pickVideo(ImageSource source) async {
  final pickVideo = await ImagePicker().pickVideo(source: source);
  if (pickVideo != null) {
    final video = File(pickVideo.path);
    return video.path;
  } else {
    return '';
  }
}

// Future<GiphyGif?> pickGIF(BuildContext context) async {
//   GiphyGif? gif;
//   try {
//     gif = await Giphy.getGif(
//       context: context,
//       apiKey: 'pwXu0t7iuNVm8VO5bgND2NzwCpVH9S0F',
//     );
//   } catch (e) {
//     showSnackBar(context: context, content: e.toString());
//   }
//   return gif;
// }
// void showSnackBar({required BuildContext context, required String content}) {
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       content: Text(content),
//     ),
//   );
// }

List<T> modelBuilder<M, T>(
        List<M> models, T Function(int index, M model) builder) =>
    models
        .asMap()
        .map<int, T>((index, model) => MapEntry(index, builder(index, model)))
        .values
        .toList();

String printDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(
    duration.inMinutes.remainder(60),
  );
  String twoDigitSeconds = twoDigits(
    duration.inSeconds.remainder(60),
  );
  if (duration.inHours > 0) {
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
  return "$twoDigitMinutes:$twoDigitSeconds";
}

String formatDateString(String? input, {String format = 'yyyy/MM/dd'}) {
  try {
    if (input == null) {
      return '';
    }
    DateTime inputDate = DateTime.parse(input);
    final DateFormat formatter = DateFormat(format);
    return formatter.format(inputDate);
  } catch (ignore) {
    return '';
  }
}

String convertTimestampToDateTime(Timestamp? timestamp) => (timestamp != null)
    ? DateFormat('dd/MM/yy hh:mm a').format(timestamp.toDate())
    : '';

MessageType getMessageType(String? type) {
  if (type == MessageType.text.name) {
    return MessageType.text;
  } else if (type == MessageType.image.name) {
    return MessageType.image;
  } else if (type == MessageType.video.name) {
    return MessageType.video;
  } else {
    return MessageType.audio;
  }
}

String setMessageType(MessageType? type) {
  if (type == MessageType.text) {
    return MessageType.text.name;
  } else if (type == MessageType.image) {
    return MessageType.image.name;
  } else if (type == MessageType.video) {
    return MessageType.video.name;
  } else {
    return MessageType.audio.name;
  }
}

String formatDate(String? value) {
  final DateTime? dateTime = DateTime.tryParse(value ?? '');
  if (isNullOrEmpty(dateTime)) {
    return '';
  }
  return DateFormat('dd-MM-yyyy').format(dateTime!);
}

String formatDateTime(DateTime? time) {
  if (time == null) {
    return '';
  }
  DateFormat formatter = DateFormat('HH:mm dd/MM/yyyy');
  String formattedDateTime = formatter.format(time);
  return formattedDateTime;
}

MediaType getMediaType(int type) {
  switch (type) {
    case 0:
    case 1:
      return MediaType.image;
    case 2:
      return MediaType.video;
    default:
      MediaType.image;
      throw Exception('Invalid mediaType type: $type');
  }
}

int setMediaType(MediaType type) {
  switch (type) {
    case MediaType.image:
      return 1;
    case MediaType.video:
      return 2;
    default:
      //
      throw Exception('Invalid mediaType type: $type');
  }
}

double matchGPA(double? oral, m15, m45, finalE) {
  double gpa =
      ((oral ?? 0.0) + (m15 ?? 0.0) + 2 * (m45 ?? 0.0) + 3 * (finalE ?? 0.0)) /
          7;
  return double.parse(gpa.toStringAsFixed(3));
}

///----------------------Awesome Notification----------------------

/// nav Page
void loadSingletonPage(
  NavigatorState? navigatorState, {
  required String targetPage,
  required ReceivedAction receivedAction,
}) {
  // Avoid to open the notification details page over another details page already opened
  // Navigate into pages, avoiding to open the notification details page over another details page already opened
  navigatorState?.pushNamedAndRemoveUntil(
    targetPage,
    (route) {
      return (route.settings.name != targetPage) || route.isFirst;
    },
    arguments: receivedAction,
  );
}

//get device info
// Future<String> getPlatformVersion() async {
//   if (Platform.isAndroid) {
//     var androidInfo = await DeviceInfoPlugin().androidInfo;
//     var sdkInt = androidInfo.version.sdkInt;
//     return 'Android-$sdkInt';
//   }
//
//   if (Platform.isIOS) {
//     var iosInfo = await DeviceInfoPlugin().iosInfo;
//     var systemName = iosInfo.systemName;
//     var version = iosInfo.systemVersion;
//     return '$systemName-$version';
//   }
//
//   return 'unknown';
// }

Future<String> downloadAndSaveImageOnDisk(String url, String fileName) async {
  var directory = await getApplicationDocumentsDirectory();
  var filePath = '${directory.path}/$fileName';
  var file = File(filePath);

  if (!await file.exists()) {
    var response = await Dio().get(url);
    await file.writeAsBytes(response.data);
  }

  return filePath;
}

void lockScreenPortrait() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

void unlockScreenPortrait() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}
