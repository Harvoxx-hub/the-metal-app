abstract class Environment {
  static const dev = 'dev';
  static const prod = 'prod';

  static String get current {
    return const String.fromEnvironment('FLAVOR', defaultValue: prod);
  }

  static bool get isDev => current == dev;
  static bool get isProd => current == prod;

  static String get apiUrl {
    switch (current) {
      case dev:
        return 'https://dev-api.metal.com'; // Update with your actual dev API URL
      case prod:
        return 'http://ec2-54-237-199-205.compute-1.amazonaws.com:9000';
      default:
        return 'http://ec2-54-237-199-205.compute-1.amazonaws.com:9000';
    }
  }

  static String get appName {
    switch (current) {
      case dev:
        return 'Metal Dev';
      case prod:
        return 'Metal';
      default:
        return 'Metal';
    }
  }
}
