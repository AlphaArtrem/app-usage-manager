import 'package:appusagemanager/classes/database.dart';
import 'package:appusagemanager/common/formatting.dart';
import 'package:flutter/material.dart';

class TrackApps extends StatefulWidget {
  @override
  _TrackAppsState createState() => _TrackAppsState();
}

class _TrackAppsState extends State<TrackApps> {
  final _database = TrackedAppsDatabase.instance;
  int _rowCount;

  void setup() async{
    _rowCount = await _database.getRowCount();
    setState(() {});
  }

  @override
  void initState(){
    super.initState();
    setup();
  }
  @override
  Widget build(BuildContext context) {
    return Center(
        child: _rowCount == null ? loader : Padding(
          padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
          child: Text("You are not tracking any app usage."),
        ),
    );
  }

  Widget _trackApp(){
    return Container();
  }
}
