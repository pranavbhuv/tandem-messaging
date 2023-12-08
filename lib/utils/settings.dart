class Settings {

  static final Settings _instance = Settings._internal();

  Settings._internal();

  factory Settings() {
    return _instance;
  }

  String getIP() {
    return "34.72.167.150";
  }
}
