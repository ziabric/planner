import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'TextEditor.dart';

import 'Database.dart';

class MainWindow extends StatefulWidget {
  const MainWindow({super.key});

  @override
  _MainWindowState createState() => _MainWindowState();

}

class _MainWindowState extends State<MainWindow> with TickerProviderStateMixin {
  final TextEditingController _taskTitle = TextEditingController();

  late DateTime _currentDate = DateTime.now();
  late TabController tabController;

  @override
  void dispose() {
    // Очищаем контроллеры, чтобы избежать утечек памяти
    _taskTitle.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(initialIndex: 0, length: 4, vsync: this);
  }

  List<dynamic> _eventLoader(DateTime dateTimeForEvent) {
    
    return [];
  }

  @override
  Widget build(BuildContext context) {

    print("start rebuild");

    return Scaffold(
      body: Stack(
        children: [ 
          TabBarView(
            controller: tabController,
            children: [
              Container(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _currentDate = DateTime.now();
                            });
                          }, 
                          child: const Text("Current")
                        ),
                        IconButton(
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
                          }, 
                          icon: const Icon(Icons.add)
                        )
                      ],
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
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    IconButton(
                                      onPressed: () {
                                        DBProvider.db.deleteTask(_currentDate, item["title"].toString());
                                        setState(() {
                                          
                                        });
                                      }, 
                                      icon: const Icon(Icons.delete)
                                    )
                                  ],
                                )
                              )
                            );
                          }
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: output,
                          );
                        }
                        else 
                        {
                          return const Center(child: Text("Error"),);
                        }
                      } 
                    ),
                  ],
                ),
              ),
              const TextEditor(),
              const Center(child: Text("data"),),
              const Center(child: Text("data"),),
            ]
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: TabBar(
              automaticIndicatorColorAdjustment: false,
              dividerColor: Colors.white,
              indicatorColor: Colors.white,
              labelPadding: const EdgeInsets.all(30),
              controller: tabController,
              tabs: const [
                Tab(child: Icon(Icons.calendar_month),),
                Tab(child: Icon(Icons.edit_document),),
                Tab(child: Icon(Icons.abc_sharp),),
                Tab(child: Icon(Icons.abc_sharp),),
              ]
            ),
          )
        ]
      )
    );
  }
}