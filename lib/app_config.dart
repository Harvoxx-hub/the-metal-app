import 'package:metal/core/utils/constant/constants.dart';

bool isDarkMode = false;

class AppConfig {
  late Flavour _flavour;

  static final AppConfig config = AppConfig._();

  AppConfig._();

  factory AppConfig.init({required Flavour flavour}) {
    config._flavour = flavour;
    _initialize();
    return config;
  }

  Flavour get flavor => _flavour;

  String get url => _flavour.maybeWhen(
        dev: () => devBaseUrl,
        prod: () => baseUrl,
      );

  String get name => _flavour.maybeWhen(
        dev: () => "$appName Dev",
        prod: () => kPackageName,
      );

  String get appPackageName => _flavour.maybeWhen(
        dev: () => kPackageNameDev,
        prod: () => kPackageName,
      );

  static _initialize() async {}
}

enum Flavour {
  prod('prod'),
  dev('dev');

  final String name;

  const Flavour(this.name);

  static Flavour valueOf(String name) =>
      Flavour.values.firstWhere((e) => e.name == name);

  bool get isProd => this == Flavour.prod;

  bool get isDev => this == Flavour.dev;

  U maybeWhen<U>({
    U Function()? dev,
    U Function()? prod,
  }) {
    switch (this) {
      case Flavour.dev:
        return dev!.call();
      case Flavour.prod:
        return prod!.call();
    }
  }
}
