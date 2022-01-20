import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
//import 'package:geocoding/geocoding.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Map<String, Marker> _markers = {};
  Future<void> _onMapCreated(GoogleMapController controller) async {
    final infectionCase = await getInfectionCase();
    for (final infection in infectionCase) {
      infection["coordinate"] = await getcorrdinate(infection["Building name"]);
    }
    print(infectionCase);
    setState(() {
      _markers.clear();
      for (final infection in infectionCase) {
        print("HHHHH");
        final marker = Marker(
          markerId: MarkerId(infection["Related cases"]),
          position: LatLng(
              infection["coordinate"]["lat"], infection["coordinate"]["lng"]),
          infoWindow: InfoWindow(
            title: infection["Related cases"],
            snippet: infection["Building name"],
          ),
        );
        _markers[infection["Related cases"]] = marker;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Google Office Locations'),
          backgroundColor: Colors.green[700],
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: const CameraPosition(
            target: LatLng(0, 0),
            zoom: 2,
          ),
          markers: _markers.values.toSet(),
        ),
      ),
    );
  }
}

Future<dynamic> getInfectionCase() async {
  const govURL =
      //"https://api.data.gov.hk/v2/filter?q=%7B%22resource%22%3A%22http%3A%2F%2Fwww.chp.gov.hk%2Ffiles%2Fmisc%2Fbuilding_list_eng.csv%22%2C%22section%22%3A1%2C%22format%22%3A%22json%22%2C%22filters%22%3A%5B%5B2%2C%22eq%22%2C%5B%22Penny's%20Bay%20Quarantine%20Centre%22%5D%5D%2C%5B4%2C%22bw%22%2C%5B%221302%22%5D%5D%5D%7D";
      'https://api.data.gov.hk/v2/filter?q=%7B%22resource%22%3A%22http%3A%2F%2Fwww.chp.gov.hk%2Ffiles%2Fmisc%2Fbuilding_list_eng.csv%22%2C%22section%22%3A1%2C%22format%22%3A%22json%22%2C%22filters%22%3A%5B%5B4%2C%22bw%22%2C%5B%221300%22%5D%5D%5D%7D';

  // Retrieve the locations of Google offices
  try {
    final response = await http.get(Uri.parse(govURL));
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      return result;
    }
  } catch (e) {
    print(e);
  }
}

Future<dynamic> getcorrdinate(buildingName) async {
  const String apikey = "APIKEY";
  String geoAPI =
      "https://maps.googleapis.com/maps/api/geocode/json?address=$buildingName&key=$apikey";
  try {
    final response = await http.get(Uri.parse(geoAPI));
    var result = jsonDecode(response.body);
    return result["results"][0]["geometry"]["location"];
  } catch (e) {
    print(e);
  }
}
