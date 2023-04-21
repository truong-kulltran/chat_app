class ApiPath {
  static const String apiDomain = 'http://192.168.1.26:8080';
  static const String apiDomainMac = 'http://10.10.142.45:8080';

  //change [useMac] - false: ip window
  //                - true: ip mac
  static const bool useMac = false;

  static const String domain = useMac ? apiDomainMac : apiDomain;

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
}
