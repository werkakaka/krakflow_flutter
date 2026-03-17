import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("KrakFlow"),
        ),
        body: Center(
          child: Column(
            children: [
              const Text("KrakFlow"),
              const Text("Organizacja studiów"),
              const Text("Dzisiejsze zadania"),
            ],
          ),
        ),
      ),
    );
  }
}