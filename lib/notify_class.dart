class Notify {
  final String name;
  final String message;
  final String nID;
  final List cIDList;
  final bool sendLocation;
  final bool requestCheckIn;
  final bool isConditional;

  const Notify({
    required this.name,
    required this.message,
    required this.sendLocation,
    required this.requestCheckIn,
    required this.isConditional,
    required this.nID,
    required this.cIDList
  });

  factory Notify.fromRTDB(Map<dynamic,dynamic> data, nID) {
    return Notify(
      name: data["name"],
      message: data["message"],
      nID: nID,
      sendLocation: data["sendLocation"] as bool,
      requestCheckIn: data["requestCheckIn"] as bool,
      isConditional: data["isConditional"] as bool,
      cIDList: data["cIDList"] as List
    );
  }
}