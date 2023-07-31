import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:color_code/AddCarScreen.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Fuel Efficient Vehicles'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});



  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  CollectionReference _referenceVehicleList = FirebaseFirestore.instance.collection('vehicles');
  late Stream<QuerySnapshot> _streamVehicles;

  void _incrementCounter() {
    setState(() {

      _counter++;
    });
  }

  initState() {
    super.initState();

    _streamVehicles = _referenceVehicleList.snapshots();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _streamVehicles,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          if (snapshot.connectionState == ConnectionState.active) {
            QuerySnapshot querySnapshot = snapshot.data!;
            List<QueryDocumentSnapshot> vehicles = querySnapshot.docs;

            return ListView.builder(
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                // Extract data from the document snapshot and cast it to Map<String, dynamic>
                var vehicleData = vehicles[index].data() as Map<String, dynamic>?;

                if (vehicleData == null) {
                  // Handle the case where vehicleData is null (optional)
                  return Container(); // You can return an empty container or any other widget
                }

                // Access the fields from the vehicleData map
                var brand = vehicleData['brand'];
                var imageUrl = vehicleData['imageUrl'];
                var kmpl = (vehicleData['kmpl'] ?? 0.0) as double; // Convert to double, handle null case
                var model = vehicleData['model'];
                var year = (vehicleData['year'] ?? 0).toInt(); // Convert to int, handle null case

                // Display the vehicle details using the custom VehicleCard widget
                return VehicleCard(
                  brand: brand,
                  imageUrl: imageUrl,
                  kmpl: kmpl,
                  model: model,
                  year: year,
                );
              },
            );



          }

          return Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the AddCarScreen when the FloatingActionButton is pressed
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCarScreen()),
          );
        },
        tooltip: 'Add Car',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class VehicleCard extends StatelessWidget {
  final String brand;
  final String imageUrl;
  final double kmpl;
  final String model;
  final int year;

  const VehicleCard({
    required this.brand,
    required this.imageUrl,
    required this.kmpl,
    required this.model,
    required this.year,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the color based on fuel efficiency and age
    Color cardColor;
    if (kmpl >= 15.0 && year >= DateTime.now().year - 5) {
      // Fuel efficient and low pollutant (Green)
      cardColor = Colors.green;
    } else if (kmpl >= 15.0 && year < DateTime.now().year - 5) {
      // Fuel efficient but moderately pollutant (Amber)
      cardColor = Colors.amber;
    } else {
      // Everything else (Red)
      cardColor = Colors.red;
    }

    return Card(
      // Customize the appearance of the card with the determined color
      color: cardColor,
      elevation: 5,
      child: Column(
        children: [
          // Display the image using the NetworkImage widget
          Image.network(imageUrl),

          // Display the vehicle details using ListTile
          ListTile(
            title: Text(
              brand,
              style: TextStyle(color: Colors.white), // Set the brand text color to white
            ),
            subtitle: Text(
              '$model ($year)',
              style: TextStyle(color: Colors.white), // Set the model and year text color to white
            ),
            trailing: Text(
              '${kmpl.toStringAsFixed(1)} kmpl',
              style: TextStyle(color: Colors.white), // Set the kmpl text color to white
            ),
          ),
        ],
      ),
    );
  }
}
