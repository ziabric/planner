import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:sqflite/sqflite.dart';

import 'Database.dart';

class MainWindow extends StatefulWidget {
  const MainWindow({super.key});

  @override
  _MainWindowState createState() => _MainWindowState();

}

class _MainWindowState extends State<MainWindow> {
  final TextEditingController _taskTitle = TextEditingController();

  late DateTime _currentDate = DateTime.now();

  @override
  void dispose() {
    // Очищаем контроллеры, чтобы избежать утечек памяти
    _taskTitle.dispose();
    super.dispose();
  }

  List<dynamic> _eventLoader(DateTime dateTimeForEvent) {
    
    return [];
  }

  @override
  Widget build(BuildContext context) {

    print("start rebuild");

    return Scaffold(

      // floatingActionButton: Row(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: <Widget>[
      //     IconButton(onPressed: () {}, icon: const Icon(Icons.access_alarm)),
      //     IconButton(onPressed: () {}, icon: const Icon(Icons.access_alarm)),
      //     IconButton(onPressed: () {}, icon: const Icon(Icons.access_alarm)),
      //     IconButton(onPressed: () {}, icon: const Icon(Icons.access_alarm)),
      //   ],
      // ),
      // appBar: AppBar(
      //   title: const Text("Calendar"),
      // ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.edit),
        onPressed: () {
          showDialog(
            context: context, 
            builder: (context) {
              return Dialog(
                child: Container(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextField(
                        decoration: const InputDecoration(labelText: 'Title'),
                        controller: _taskTitle,
                      ),
                      TextButton.icon(
                        onPressed: () {
                          DBProvider.db.addTask(_currentDate, _taskTitle.text);
                          setState(() {
                            _taskTitle.text = "";
                          });
                          Navigator.pop(context);
                        }, 
                        icon: const Icon(Icons.save), 
                        label: const Text("Save")
                      )
                    ],
                  ),
                )
              );
            }
          );
        }
      ),
      body: Container(
            padding: const EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                TableCalendar(
                  eventLoader: _eventLoader,
                  currentDay: _currentDate,
                  onDaySelected: (DateTime prev, DateTime cur) {
                    setState(() {
                      _currentDate = cur;
                    });
                  },
                  firstDay: DateTime.utc(2010, 10, 16),
                  lastDay: DateTime.utc(2030, 3, 14),
                  focusedDay: DateTime.now(),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _currentDate = DateTime.now();
                    });
                  }, 
                  child: const Text("Current")
                ),
                FutureBuilder(
                  future: DBProvider.db.getEvents(_currentDate), 
                  builder:(context, snapshot) {
                    // if (!snapshot.hasError)
                    if ( !snapshot.hasError )
                    {
                      List<Widget> output = [];
                      for (var item in snapshot.data!)
                      {
                        output.add(
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Checkbox(value: (int.parse(item["complite"].toString()) == 0) ? false : true, onChanged: (value) async {
                                  await DBProvider.db.setState(_currentDate, item["title"].toString(), (value == true) ? 1 : 0);
                                  setState(() {
                                  });
                                }),
                                Text(
                                  item["title"].toString(),
                                  style: const TextStyle(
                                    fontSize: 20
                                  ),
                                ),
                              ],
                            )
                          )
                        );
                      }
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: output,
                      );
                      // return Text(snapshot.data![0]["title"].toString());
                      // return ListView.builder(
                      //   itemCount: snapshot.data!.length,
                      //   itemBuilder: (context, index) {
                      //     return Container(
                      //       padding: const EdgeInsets.all(30),
                      //       child: Text(snapshot.data![index]["title"].toString())
                      //     );
                      //   },
                      // );
                    }
                    else 
                    {
                      return const Center(child: Text("Error"),);
                    }
                  } )
              ],
            ),
          )
    );
  }
}