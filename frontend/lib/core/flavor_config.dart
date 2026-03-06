enum Flavor {
  dev,
  prod,
}

class FlavorConfig {
  final Flavor flavor;
  final String apiBaseUrl;
  final String appTitle;

  static FlavorConfig? _instance;

  FlavorConfig._internal({
    required this.flavor,
    required this.apiBaseUrl,
    required this.appTitle,
  });

  factory FlavorConfig({
    required Flavor flavor,
    required String apiBaseUrl,
    required String appTitle,
  }) {
    _instance = FlavorConfig._internal(
      flavor: flavor,
      apiBaseUrl: apiBaseUrl,
      appTitle: appTitle,
    );
    return _instance!;
  }

  static FlavorConfig get instance {
    return _instance!;
  }

  static bool isDev() => _instance?.flavor == Flavor.dev;
  static bool isProd() => _instance?.flavor == Flavor.prod;
}
