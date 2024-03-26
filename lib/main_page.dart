import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Math Solver'),
          backgroundColor: Colors.green[200],
        ),
        body: Text('Math Solver'),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          tooltip: 'Pick Image',
          child: Icon(Icons.camera_alt),
        ),
      );
}
