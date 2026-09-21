class AppConstants {
  String get baseUrl => 'https://ezworkapp.com';

  Duration get connectTimeout => const Duration(seconds: 30);

  Duration get responseTimeOut => const Duration(seconds: 30);

  String get mailMyWo => 'ezworkapp247@gmail.com';

  String get iOSAppId => '6504037312';
}

class StagingAppConstants extends AppConstants {
  @override
  String get baseUrl => 'https://dev.ezworkapp.com';

  @override
  Duration get connectTimeout => const Duration(seconds: 5);

  @override
  Duration get responseTimeOut => const Duration(seconds: 5);

  @override
  String get iOSAppId => '6450990821';
}

class DevelopmentAppConstants extends StagingAppConstants {}
