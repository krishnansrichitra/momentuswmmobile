class AppConfig {

  static const bool isLocal = true;

  static String get apiBaseUrl {
    if (isLocal) {
      return "http://10.181.85.77:9150";
    }

    return "https://momentusone.com/wms";
  }
}