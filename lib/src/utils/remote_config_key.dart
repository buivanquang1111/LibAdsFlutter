class RemoteConfigKey {
  String name;
  dynamic defaultValue;
  final Type valueType;

  RemoteConfigKey(
      {required this.name,
      required this.defaultValue,
      required this.valueType});

  void updateDefaultValue({dynamic newDefaultValue}){
    defaultValue = newDefaultValue;
  }

  static late List<RemoteConfigKey> listRemoteConfigKey;

  static void initializeKeys(List<RemoteConfigKey> keys) {
    listRemoteConfigKey = keys;
  }

  static RemoteConfigKey getKeyByName(String keyName) {
    return listRemoteConfigKey.firstWhere(
          (key) => key.name == keyName,
    );
  }

}
