class AppConfig {

  static const bool isLocal = true;

  static String get apiBaseUrl {
    if (isLocal) {
      return "http://10.54.68.203:9150";
    }

    return "https://momentusone.com/wms";
  }
}