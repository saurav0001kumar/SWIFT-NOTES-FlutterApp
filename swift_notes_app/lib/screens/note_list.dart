import 'dart:async';
import 'package:flutter/material.dart';
import 'package:swiftnotesapp/models/note.dart';
import 'package:swiftnotesapp/utils/database_helper.dart';
import 'package:swiftnotesapp/screens/note_detail.dart';
import 'package:sqflite/sqflite.dart';


class NoteList extends StatefulWidget {

	@override
  State<StatefulWidget> createState() {

    return NoteListState();
  }
}

class NoteListState extends State<NoteList> {

	DatabaseHelper databaseHelper = DatabaseHelper();
	List<Note> noteList;
	int count = 0;

	@override
  Widget build(BuildContext context) {

		if (noteList == null) {
			noteList = List<Note>();
			updateListView();
		}

    return Scaffold(

	    appBar: AppBar(
		    title: Text('Swift Notes'),
				leading: Icon(Icons.speaker_notes),
				actions: <Widget>[
					Padding(
						padding: EdgeInsets.only(right: 10),

						child:IconButton(
							icon:Icon(Icons.info_outline),
							tooltip: "About",
							iconSize: 27,
							color: Colors.white,
							onPressed: (){
								help();
							},

						),



					)

				],
	    ),

	    body: getNoteListView(),

	    floatingActionButton: FloatingActionButton.extended(
		    onPressed: () {
		      debugPrint('FAB clicked');
		      navigateToDetail(Note('', '', 2), 'Add Note');
		    },
				icon: Icon(Icons.add_comment),
				label: Text("Add Note"),
				elevation: 10,
				splashColor: Colors.redAccent,
				hoverColor: Colors.redAccent,

				shape: ShapeBorder.lerp(null, null, 20),
		    tooltip: 'Add a Note',
				backgroundColor: Colors.indigo,



	    ),
    );
  }

  ListView getNoteListView() {

		TextStyle titleStyle = Theme.of(context).textTheme.subhead;

		return ListView.builder(
			itemCount: count,
			itemBuilder: (BuildContext context, int position) {
				return Card(
					color: Colors.white,
					elevation: 5.0,
					child: ListTile(

						leading: CircleAvatar(
							backgroundColor: getPriorityColor(this.noteList[position].priority),
							foregroundColor: Colors.white,
							child: getPriorityIcon(this.noteList[position].priority),
						),

						title: Text(this.noteList[position].title, style: titleStyle,),

						subtitle: Text(this.noteList[position].date),

						trailing: GestureDetector(
							child: Icon(Icons.delete_outline, color: Colors.red,),
							onTap: () {
								_delete(context, noteList[position]);
							},
						),


						onTap: () {
							debugPrint("ListTile Tapped");
							navigateToDetail(this.noteList[position],'Edit Note');
						},

					),
				);
			},
		);
  }

  // Returns the priority color
	Color getPriorityColor(int priority) {
		switch (priority) {
			case 1:
				return Colors.pink;
				break;
			case 2:
				return Colors.blue;
				break;
			case 3:
				return Colors.amber;
				break;

			default:
				return Colors.blue;
		}
	}

	// Returns the priority icon
	Icon getPriorityIcon(int priority) {
		switch (priority) {
			case 1:
				return Icon(Icons.fiber_smart_record);
				break;
			case 2:
				return Icon(Icons.fiber_manual_record);
				break;
			case 3:
				return Icon(Icons.panorama_fish_eye);
				break;

			default:
				return Icon(Icons.fiber_manual_record);
		}
	}

	void _delete(BuildContext context, Note note) async {

		int result = await databaseHelper.deleteNote(note.id);
		if (result != 0) {
			_showSnackBar(context, 'Note Deleted Successfully!');
			updateListView();
		}
	}

	void _showSnackBar(BuildContext context, String message) {

		final snackBar = SnackBar(content: Text(message));
		Scaffold.of(context).showSnackBar(snackBar);
	}

  void navigateToDetail(Note note, String title) async {
	  bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
		  return NoteDetail(note, title);
	  }));

	  if (result == true) {
	  	updateListView();
	  }
  }

  void updateListView() {

		final Future<Database> dbFuture = databaseHelper.initializeDatabase();
		dbFuture.then((database) {

			Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
			noteListFuture.then((noteList) {
				setState(() {
				  this.noteList = noteList;
				  this.count = noteList.length;
				});
			});
		});
  }

	void help() {

		AlertDialog alertDialog = AlertDialog(
			elevation: 10,
			backgroundColor: Colors.white70,
			title: Text("About App!"),
			content: Text("Swift Notes Version-1.0 . Thanks for using this app. For any help or feedback, contact the developer at 'saurav0001kumar@gmail.com' or Visit: https://saurav0001kumar.ml"),
		);
		showDialog(
				context: context,
				builder: (_) => alertDialog
		);
	}

}







