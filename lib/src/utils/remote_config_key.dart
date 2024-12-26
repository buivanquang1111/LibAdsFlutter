class RemoteConfigKeyLib {
  String name;
  dynamic defaultValue;
  final Type valueType;

  RemoteConfigKeyLib(
      {required this.name,
      required this.defaultValue,
      required this.valueType});

  void updateDefaultValue({dynamic newDefaultValue}) {
    defaultValue = newDefaultValue;
  }

  static List<RemoteConfigKeyLib> listRemoteConfigKey = [];

  static void initializeKeys(List<RemoteConfigKeyLib> keys) {
    print('check_remote_config: initializeKeys');
    listRemoteConfigKey = keys;
    print('check_remote_config: listRemoteConfigKey');
    for (var element in listRemoteConfigKey) {
      print(
          'check_remote_config: initializeKeys - ${element.name}, ${element.defaultValue}');
    }

    print('check_remote_config: keys');
    for (var element in keys) {
      print(
          'check_remote_config: initializeKeys - ${element.name}, ${element.defaultValue}');
    }
  }

  static void ensureInitialized() {
    if (listRemoteConfigKey.isEmpty) {
      throw Exception(
          'RemoteConfigKeyLib has not been initialized. Call initializeKeys() first.');
    }
  }

  static RemoteConfigKeyLib getKeyByName(String keyName) {
    ensureInitialized();
    return listRemoteConfigKey.firstWhere(
      (key) => key.name == keyName,
      orElse: () => throw Exception('Key not found: $keyName'),
    );
  }
}
