import 'package:appusagemanager/widgets/apps_used.dart';
import 'package:appusagemanager/widgets/track_apps.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _installedApps = [];
  Map<String, double> _appUsage;
  int _selectedIndex = 0;

  Map _screens = {
    'Apps Used Today' : AppsUsedToday(),
    'Tracked Apps' : TrackApps(),
  };

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_screens.keys.toList()[_selectedIndex]),
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
      body: _screens[_screens.keys.toList()[_selectedIndex]],
    );
  }

}
