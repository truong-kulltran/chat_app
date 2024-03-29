class ApiPath {
  static const String domain = 'http://167.99.65.226:8080';

  static const String agoraServerDomain =
      'https://agora-token-service-production-dabe.up.railway.app';

  //https://agora-token-service-production-dabe.up.railway.app/rtc/<channel>/1/uid/<uid>/

  static const String signup = '$domain/api/auth/sign-up';

  static const String login = '$domain/api/auth/sign-in';

  static const String changePassword = '$domain/api/auth/change-password';

  static const String forgotPassword = '$domain/api/auth/forgot-password';

  static const String newPassword = '$domain/api/auth/new-password';

  static const String refreshToken = '$domain/api/auth/refresh-token';

  static const String sendOtp = '$domain/api/auth/send-otp';

  static const String fillProfile = '$domain/api/v1/users/';

  static const String listNews = '$domain/api/v1/news';

  static const String upLoadImageToCloud = '$domain/api/v1/news/upload';

  static const String listClass = '$domain/api/v1/classes';

  static const String listSubject = '$domain/api/v1/subjects';

  static const String listStudent = '$domain/api/v1/students';

  static const String getStudentInfo = '$domain/api/v1/students/detail';

  static const String learningResult = '$domain/api/v1/learning-result';

  static const String fcmGoogle =
      'https://fcm.googleapis.com/v1/projects/chatapp-97dbc/messages:send';

  static const String fcmServer = 'https://fcm.googleapis.com/fcm/send';
}
