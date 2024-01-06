import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart'as http;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:swaroopabawaletask/CalculateLatLangVal.dart';

// import 'package:workmanager/workmanager.dart';

Future<bool> _handleLocationPermission() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return false;
  }
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return false;
    }
  }
  if (permission == LocationPermission.deniedForever) {
    return false;
  }
  return true;
}

Future<void> _getCurrentPosition() async {
  final hasPermission = await _handleLocationPermission();

  if (!hasPermission) return;
  await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
      .then((Position position)async {

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

//
// void callbackDispatcher() {
//   Workmanager().executeTask((taskName, inputData)async {
//    await _getCurrentPosition();
//     return Future.value(true);
//   });
// }

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Workmanager().initialize(callbackDispatcher);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CalculateLatLandVal(),
    );
  }
}

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key}) : super(key: key);
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: const Text("Work manager Example"),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             ElevatedButton(
//                 onPressed: () {
//                   Workmanager().registerOneOffTask(
//                     "taskOne",
//                     "backUp",
//                     initialDelay: Duration(seconds: 1),
//                   );
//                 },
//                 child: Text("Run Task")),
//             SizedBox(
//               height: 10,
//             ),
//             ElevatedButton(
//                 onPressed: () {
//                   Workmanager().cancelByUniqueName("taskOne");
//                 },
//                 child: Text("Cancel Task"))
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     Workmanager().registerPeriodicTask(
//       "taskTwo",
//       "backUp",
//       frequency: Duration(hours: 1),
//     );
//   }
// }