import 'package:flutter/material.dart';

import 'Database.dart';

class TextEditor extends StatefulWidget {
  const TextEditor({super.key});

  @override
  _TextEditorState createState() => _TextEditorState();

}

class _TextEditorState extends State<TextEditor> with TickerProviderStateMixin {

  @override
  void dispose() {
    // Очищаем контроллеры, чтобы избежать утечек памяти
    super.dispose();
  }

  List<DropdownMenuItem<String>> titles = [];
  List<TextEditingController> sources = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: DBProvider.db.getAllTexts(),
        builder: ((context, snapshot) {
          if (!snapshot.hasError)
          {
            titles.clear();
            sources.clear();

            for (var item in snapshot.data!)
            {
              titles.add(item["title"] as DropdownMenuItem<String>);
              sources.add(TextEditingController.fromValue(item["title"] as TextEditingValue?));
            }

            return Row(
              children: [
                DropdownButton<String>(items: titles, onChanged: (value) {

                }),

              ]
            );
          }
          else 
          {
            return const CircularProgressIndicator();
          }
        }),
    );
  }
}