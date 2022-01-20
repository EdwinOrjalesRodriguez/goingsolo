class Mode {
  final String name;
  final String description;
  final String mID;
  final String lat;
  final String lng;

  const Mode({
    required this.name,
    required this.description,
    required this.mID,
    required this.lat,
    required this.lng
  });

  factory Mode.fromRTDB(Map<dynamic,dynamic> data, mID) {
    return Mode(
        name: data["name"],
        description: data["description"],
        mID: mID,
        lat: data['lat'],
        lng: data['lng']
    );
  }
}