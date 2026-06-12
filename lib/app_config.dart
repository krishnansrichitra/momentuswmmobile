class AppConfig {

  static const bool isLocal = true;

  static String get apiBaseUrl {
    if (isLocal) {
      return "http://10.20.74.160:9150";
    }

    return "https://momentusone.com/wms";
  }
}