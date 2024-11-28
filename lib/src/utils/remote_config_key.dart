class RemoteConfigKeyLib {
  String name;
  dynamic defaultValue;
  final Type valueType;

  RemoteConfigKeyLib(
      {required this.name,
      required this.defaultValue,
      required this.valueType});

  void updateDefaultValue({dynamic newDefaultValue}){
    defaultValue = newDefaultValue;
  }

  static late List<RemoteConfigKeyLib> listRemoteConfigKey;

  static void initializeKeys(List<RemoteConfigKeyLib> keys) {
    listRemoteConfigKey = keys;
  }

  static RemoteConfigKeyLib getKeyByName(String keyName) {
    return listRemoteConfigKey.firstWhere(
          (key) => key.name == keyName,
    );
  }

}
