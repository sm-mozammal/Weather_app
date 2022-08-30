import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WeatherPage extends StatefulWidget {
  static const String routeName = '/';
  const WeatherPage({Key? key}) : super(key: key);

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Weather App'),
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(Icons.my_location)

          ),
          IconButton(
              onPressed: () {},
              icon: Icon(Icons.search)

          ),
          IconButton(
              onPressed: () {},
              icon: Icon(Icons.settings)

          ),
        ],
      ),
    );
  }
}
