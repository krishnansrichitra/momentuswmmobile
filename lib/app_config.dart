class AppConfig {

  static const bool isLocal = true;

  static String get apiBaseUrl {
    if (isLocal) {
      return "http://10.44.0.74:9150";
    }

    return "https://momentusone.com/wms";
  }
}