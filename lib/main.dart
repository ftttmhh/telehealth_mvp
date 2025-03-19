import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(TeleHealthApp());
}

class TeleHealthApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final String tollFreeNumber = "tel:+17623483383"; // Replace with actual Twilio number

  _makeCall() async {
    if (await canLaunch(tollFreeNumber)) {
      await launch(tollFreeNumber);
    } else {
      throw 'Could not launch $tollFreeNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Rural TeleHealth")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.call, size: 100, color: Colors.green),
            SizedBox(height: 20),
            Text(
              "Call Our Toll-Free Healthcare Line",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _makeCall,
              child: Text("Call Now"),
              style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15)),
            ),
          ],
        ),
      ),
    );
  }
}
