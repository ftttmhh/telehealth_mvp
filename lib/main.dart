import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(TeleHealthApp());
}

class TeleHealthApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _queryController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String _response = '';
  String _selectedLanguage = 'en';
  final String apiUrl = 'https://telehealth-voice-assistant.onrender.com/api';

  Future<void> _requestCallback() async {
    if (_phoneController.text.isEmpty) {
      setState(() {
        _response = 'Please enter your phone number';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _response = '';
    });

    try {
      final Uri requestUri = Uri.parse('$apiUrl/request-callback');
      print('Starting callback request to: $requestUri');
      
      final response = await http.post(
        requestUri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone_number': _phoneController.text,
          'language': _selectedLanguage,
          'health_concern': _queryController.text,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          _response = 'We will call you back shortly at ${_phoneController.text}';
          _isLoading = false;
        });
      } else {
        throw 'Failed to request callback';
      }
    } catch (e) {
      print('Error requesting callback: $e');
      setState(() {
        _response = 'Could not request callback. Please try again later.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rural TeleHealth"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.health_and_safety, size: 80, color: Colors.green),
                    SizedBox(height: 16),
                    Text(
                      "AI Voice Health Assistant",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Get a free callback from our AI health advisor in your language",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 24),
                    TextField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Your Phone Number',
                        hintText: 'Enter your phone number',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Language',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedLanguage,
                      items: [
                        DropdownMenuItem(value: 'en', child: Text('English')),
                        DropdownMenuItem(value: 'hi', child: Text('Hindi')),
                        DropdownMenuItem(value: 'ta', child: Text('Tamil')),
                        DropdownMenuItem(value: 'te', child: Text('Telugu')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedLanguage = value!;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _queryController,
                      decoration: InputDecoration(
                        labelText: 'Health Concern (Optional)',
                        hintText: 'Describe your symptoms',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _requestCallback,
                      icon: _isLoading 
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white),
                          )
                        : Icon(Icons.call_received),
                      label: Text(_isLoading ? "Requesting..." : "Request Callback"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    if (_response.isNotEmpty) ...[
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _response.contains('call you back')
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _response.contains('call you back')
                                ? Colors.green.shade200
                                : Colors.red.shade200,
                          ),
                        ),
                        child: Text(
                          _response,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _response.contains('call you back')
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
