import 'package:flutter/material.dart';
import 'package:keepnotesapp/screens/note_list.dart';
import 'package:keepnotesapp/screens/note_detail.dart';

void main() {
	runApp(MyApp());
}

class MyApp extends StatelessWidget {

	@override
  Widget build(BuildContext context) {

    return MaterialApp(
	    title: 'Swift Notes',
	    debugShowCheckedModeBanner: false,
	    theme: ThemeData(
					hoverColor:Colors.blueAccent,
					accentColor:Colors.indigoAccent,
					dividerColor: Colors.lightBlue,
					highlightColor: Colors.lightBlueAccent,
					primarySwatch: Colors.indigo,

	    ),
	    home: NoteList(),
    );
  }
}