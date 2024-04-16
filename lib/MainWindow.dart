import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:sqflite/sqflite.dart';

class MainWindow extends StatefulWidget {
  const MainWindow({super.key});

  @override
  _MainWindowState createState() => _MainWindowState();
}

class _MainWindowState extends State<MainWindow> {
  final TextEditingController _controllerOne = TextEditingController();
  final TextEditingController _controllerTwo = TextEditingController();
  final TextEditingController _controllerThree = TextEditingController();

  late DateTime _currentDate = DateTime.now();

  late Database db;

  @override
  void dispose() {
    // Очищаем контроллеры, чтобы избежать утечек памяти
    _controllerOne.dispose();
    _controllerTwo.dispose();
    _controllerThree.dispose();
    super.dispose();
  }

  void _opendb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "internal.db");
    final exist = await databaseExists(path);

    if (exist) {
      print("Exist");
    }else{
      print("Not exist");

      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (e) {
        ByteData data = await rootBundle.load(join("assets", "internal.db"));
        List<int> bytes = data.buffer.asInt8List(data.offsetInBytes, data.lengthInBytes);

        await File(path).writeAsBytes(bytes, flush: true);
        print("copied!");
      }
    }
    db = await openDatabase(path);
    print(db.isOpen.toString());
  }

  List<dynamic> _eventLoader(DateTime dateTimeForEvent) {

    return [];
  }

  Future<List<Map<String, bool>>> _getEvents(DateTime dateTime) async {
    final answer = await db.query("Events");

    List<Map<String, bool>> output = [];

    for (var item in answer ) {
      if ( item["day"] == dateTime.day && item["month"] == dateTime.month && item["year"] == dateTime.year) {
        output.add({item["title"], item["complite"]} as Map<String, bool>);
      }
    }

    return output;
  }

  @override
  Widget build(BuildContext context) {

    _opendb();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendar"),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
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
            TextButton.icon(
              onPressed: (){

              }, 
              icon: const Icon(Icons.mode_edit), 
              label: const Text("Add")
            ),
            FutureBuilder(future: _getEvents(_currentDate), builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        Checkbox(value: snapshot.data?[index]["complite"], onChanged: (value) {
                          
                        }),
                        Text(snapshot.data![index].toString())
                      ],
                    );
                  },
                );
              }
            })
          ],
        ),
      )
    );
  }
}