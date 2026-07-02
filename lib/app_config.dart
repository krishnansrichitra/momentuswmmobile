class AppConfig {

  static const bool isLocal = true;

  static String get apiBaseUrl {
    if (isLocal) {
      return "http://127.0.0.1:9150";
    }

    return "https://momentusone.com/wms";
  }
}