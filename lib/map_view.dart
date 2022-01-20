import 'package:flutter/material.dart';
import 'package:going_solo/contacts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapViewPage extends StatefulWidget {
  const MapViewPage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MapViewPage> createState() => _MapViewPageState();
}

class _MapViewPageState extends State<MapViewPage> {
  final Location location = Location();
  var latitude = "";
  var longitude = "";
  bool loaded = false;
  LatLng _kMapCenter = const LatLng(0, 0);
  CameraPosition _kInitialPosition = const CameraPosition(target: LatLng(0, 0), zoom: 11.0, tilt: 0, bearing: 0);

  void _onMapCreated(GoogleMapController) {
  }

  _sharePin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ContactsPage(title: "Select Contact", latitude: latitude, longitude: longitude,)),
    );
  }

  void _dragPin(LatLng) {
    debugPrint("Dragged to " + LatLng.toString());
  }

  Set<Marker> _createMarker() {
    return {
      Marker(
        draggable: true,
        markerId: const MarkerId("marker_1"),
        position: _kMapCenter,
        infoWindow: InfoWindow(title: 'CLICK HERE TO SEND PIN', snippet: "OR DRAG THE PIN TO MOVE", onTap: _sharePin),
        onDrag: _dragPin,
      ),
    };
  }

  _insertMarker(LatLng) {
    setState(() {
      final MarkerId markerId = MarkerId("RANDOM_ID");
      Marker marker = Marker(
        markerId: markerId,
        draggable: true,
        position: LatLng, //With this parameter you automatically obtain latitude and longitude
        infoWindow: const InfoWindow(
          title: "Marker here",
          snippet: 'This looks good',
        ),
        icon: BitmapDescriptor.defaultMarker,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if(!loaded) {
      location.getLocation().then((value) {
        latitude = value.latitude.toString();
        longitude = value.longitude.toString();
        _kMapCenter = LatLng(value.latitude as double, value.longitude as double);
        _kInitialPosition = CameraPosition(target: _kMapCenter, zoom: 11.0, tilt: 0, bearing: 0);
        loaded = true;
        setState(() {
        });
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Location'),
      ),
      body: !loaded ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Center(child: Text("Loading...")),
        ],
      ) :
      GoogleMap(
        myLocationEnabled: true,
        initialCameraPosition: _kInitialPosition,
        onMapCreated: _onMapCreated,
        markers: _createMarker(),
        onLongPress: _insertMarker(_kMapCenter),
      ),
    );
  }
}

class PinInformation {
  String pinPath;
  String avatarPath;
  LatLng location;
  String locationName;
  Color labelColor;
  PinInformation({
    this.pinPath = "",
    this.avatarPath = "",
    this.location = const LatLng(34.069902502627414, -118.35891806197897),
    this.locationName = "",
    this.labelColor = Colors.yellow});
}