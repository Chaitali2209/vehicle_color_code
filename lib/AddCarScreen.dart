import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:color_code/main.dart';

class AddCarScreen extends StatefulWidget {
  @override
  _AddCarScreenState createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  // Define controllers for each form field to capture user input
  final brandController = TextEditingController();
  final imageUrlController = TextEditingController();
  final kmplController = TextEditingController();
  final modelController = TextEditingController();
  final yearController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Car'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: brandController,
              decoration: InputDecoration(labelText: 'Brand'),
            ),
            TextFormField(
              controller: imageUrlController,
              decoration: InputDecoration(labelText: 'Image URL'),
            ),
            TextFormField(
              controller: kmplController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'KMPL'),
            ),
            TextFormField(
              controller: modelController,
              decoration: InputDecoration(labelText: 'Model'),
            ),
            TextFormField(
              controller: yearController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Year'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Call a function to handle adding the car to Firestore
                addCarToFirestore();
              },
              child: Text('Add Car'),
            ),
          ],
        ),
      ),
    );
  }



  void addCarToFirestore() {
    // Get the values from the form fields
    String brand = brandController.text;
    String imageUrl = imageUrlController.text;
    double kmpl = double.tryParse(kmplController.text) ?? 0.0;
    String model = modelController.text;
    int year = int.tryParse(yearController.text) ?? 0;

    // Validate the data (you can add additional validation logic if needed)

    // Create a map with the car details
    Map<String, dynamic> carData = {
      'brand': brand,
      'imageUrl': imageUrl,
      'kmpl': kmpl,
      'model': model,
      'year': year,
    };

    // Add the car data to the 'vehicles' collection in Firestore
    FirebaseFirestore.instance.collection('vehicles').add(carData);

    // Show a snackbar or dialog to indicate successful addition
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Car added successfully!'),
    ));

    // Clear the form fields after adding the car
    brandController.clear();
    imageUrlController.clear();
    kmplController.clear();
    modelController.clear();
    yearController.clear();

    // Redirect to the MyHomePage
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage(title: 'Fuel Efficient Vehicles')),
      );
    });
  }
}
