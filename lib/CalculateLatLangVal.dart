import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart'as http;

class CalculateLatLandVal extends StatefulWidget {
  const CalculateLatLandVal({super.key});

  @override
  State<CalculateLatLandVal> createState() => _CalculateLatLandValState();
}

class _CalculateLatLandValState extends State<CalculateLatLandVal> {
  Position? _currentPosition;
  Timer? timer;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(minutes: 2), (Timer t) => _getCurrentPosition());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async{
      setState(() => _currentPosition = position);
      print(_currentPosition?.longitude);
      print(_currentPosition?.latitude);
      await PostData(position.latitude, position.longitude);
    }).catchError((e) {
      debugPrint(e);
    });
  }


  Future<dynamic> PostData(lat , lang) async{

    var formDataMap = Map<String, dynamic>();
    formDataMap['latitude'] = '$lat';
    formDataMap['longitude'] = '$lang';

    Uri u= Uri.parse("https://machinetest.encureit.com/locationapi.php");
    try {

      var response = await http.post(
        u,
        body: formDataMap,
        headers: {},
        encoding: Encoding.getByName('utf-8'),
      );
      print(response.statusCode);
      // print(data.toString());
      return response;
    }
    catch(e){


      if(e is SocketException){
        //treat SocketException
        print("Socket exception");
        throw new Exception('Check your internet connection and try again.');
        //return http.Response;
      }
      else if(e is TimeoutException){
        //treat TimeoutException
        print("Timeout exception: ${e.toString()}");
        throw new Exception('Timeout');
      }
      else {
        print("Unhandled exception: ${e.toString()}");
        throw new Exception('Server Not Reachable . Please contact Administrator ');
      }

    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Demo Task"),

      ),
      body: SafeArea(
        child:Center(
          child: ElevatedButton(
            onPressed: ()async{
              // _getLocation();
            },

            child: Text("Calculate Lat and Lang"),
          ),
        ),
      ),

    );
  }
}
