class AppConfig {

  static const bool isLocal = true;

  static String get apiBaseUrl {
    if (isLocal) {
      return "http://192.168.29.226:9150";
    }

    return "https://momentusone.com/wms";
  }
}