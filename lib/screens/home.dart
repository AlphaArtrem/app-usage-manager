import 'package:app_usage/app_usage.dart';
import 'package:appusagemanager/classes/apps_used.dart';
import 'package:appusagemanager/common/formatting.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _installedApps = [];
  Map<String, double> _appUsage;
  int _selectedIndex = 0;

  List _titles = ['Apps Used Today', 'Tracked Apps'];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: true,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes),
            title: Text('Track'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purpleAccent,
        onTap: _onItemTapped,
      ),
      body: AppsUsedToday()
    );
  }

}
