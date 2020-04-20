import 'dart:async';
import 'package:flutter/material.dart';
import 'package:keepnotesapp/models/note.dart';
import 'package:keepnotesapp/utils/database_helper.dart';
import 'package:intl/intl.dart';

class NoteDetail extends StatefulWidget {

	final String appBarTitle;
	final Note note;

	NoteDetail(this. note, this.appBarTitle);

	@override
  State<StatefulWidget> createState() {

    return NoteDetailState(this.note, this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {

	static var _priorities = ['High','Normal', 'Low'];

	DatabaseHelper helper = DatabaseHelper();

	String appBarTitle;
	Note note;

	TextEditingController titleController = TextEditingController();
	TextEditingController descriptionController = TextEditingController();

	NoteDetailState(this.note, this.appBarTitle);

	@override
  Widget build(BuildContext context) {

		TextStyle textStyle = Theme.of(context).textTheme.title;

		titleController.text = note.title;
		descriptionController.text = note.description;

    return WillPopScope(

	    onWillPop: () {
	    	// Write some code to control things, when user press Back navigation button in device navigationBar
		    moveToLastScreen();
	    },

	    child: Scaffold(
	    appBar: AppBar(
		    title: Text(appBarTitle),
		    leading: IconButton(icon: Icon(
				    Icons.arrow_back),
						tooltip: "Back",
				    onPressed: () {
		    	    // Write some code to control things, when user press back button in AppBar
		    	    moveToLastScreen();
				    }
		    ),
	    ),

	    body: Padding(
		    padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
		    child: ListView(
			    children: <Widget>[

			    	// First element
						Padding(
							padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
							child: TextField(
								controller: titleController,
								style: textStyle,
								onChanged: (value) {
									debugPrint('Something changed in Title Text Field');
									updateTitle();
								},
								decoration: InputDecoration(
										prefixIcon: Icon(Icons.title),
										labelText: 'Title',
										labelStyle: textStyle,
										hintText: "Title of your Note",
										border: OutlineInputBorder(
												borderRadius: BorderRadius.circular(5.0)
										)
								),
							),
						),

				    // Second Element
						Row(children: <Widget>[
							Padding(
								padding: EdgeInsets.fromLTRB(10,10,25,10),
								child: Text("Set Priority : ",
								style: textStyle,
							),),


							Expanded(

								child: ListTile(
								title: DropdownButton(
										icon: Icon(Icons.keyboard_arrow_down,
											color: Colors.indigoAccent,),

										items: _priorities.map((String dropDownStringItem) {
											return DropdownMenuItem<String> (
												value: dropDownStringItem,
												child: Text(dropDownStringItem),
											);
										}).toList(),

										style: textStyle,

										value: getPriorityAsString(note.priority),

										onChanged: (valueSelectedByUser) {
											setState(() {
												debugPrint('User selected $valueSelectedByUser');
												updatePriorityAsInt(valueSelectedByUser);
											});
										}
								),
							),),

						],),






				    // Third Element
				    Padding(
					    padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
					    child: TextField(
						    controller: descriptionController,
						    style: textStyle,
						    onChanged: (value) {
							    debugPrint('Something changed in Description Text Field');
							    updateDescription();
						    },
								maxLines: 7,
						    decoration: InputDecoration(
										prefixIcon: Icon(Icons.rate_review),
										hintText: "Describe your Note",
										labelText: "Description Text",
								    labelStyle: textStyle,
								    border: OutlineInputBorder(
										    borderRadius: BorderRadius.circular(5.0)
								    )
						    ),
					    ),
				    ),

				    // Fourth Element
				    Padding(
					    padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
					    child: Row(
						    children: <Widget>[
						    	Expanded(
								    child: RaisedButton(

								color: Colors.indigoAccent,
								textColor: Colors.white,
									    child: Text(
										    'SAVE',
										    textScaleFactor: 1.5,
									    ),
									    onPressed: () {
									    	setState(() {
									    	  debugPrint("Save button clicked");
									    	  _save();
									    	});
									    },
								    ),
							    ),

							    Container(width: 5.0,),

							    Expanded(
								    child: RaisedButton(
									    //color: Theme.of(context).primaryColorDark,
											textColor: Colors.indigo,
											child: Text(
												"Delete",
										    textScaleFactor: 1.5,
									    ),
									    onPressed: () {
										    setState(() {
											    debugPrint("Delete button clicked");
											    _delete();
										    });
									    },
								    ),
							    ),

						    ],
					    ),
				    ),

			    ],
		    ),
	    ),

    ));
  }

  void moveToLastScreen() {
		Navigator.pop(context, true);
  }

	// Convert the String priority in the form of integer before saving it to Database
	void updatePriorityAsInt(String value) {
		switch (value) {
			case 'High':
				note.priority = 1;
				break;
			case 'Normal':
				note.priority = 2;
				break;
			case 'Low':
				note.priority = 3;
				break;
		}
	}

	// Convert int priority to String priority and display it to user in DropDown
	String getPriorityAsString(int value) {
		String priority;
		switch (value) {
			case 1:
				priority = _priorities[0];  // 'High'
				break;
			case 2:
				priority = _priorities[1];  // 'Normal'
				break;
			case 3:
				priority = _priorities[2];  // 'Low'
				break;
		}
		return priority;
	}

	// Update the title of Note object
  void updateTitle(){
    note.title = titleController.text;
  }

	// Update the description of Note object
	void updateDescription() {
		note.description = descriptionController.text;
	}

	// Save data to database
	void _save() async {

		moveToLastScreen();

		note.date = DateFormat.yMMMd().format(DateTime.now());
		int result;
		if (note.id != null) {  // Case 1: Update operation
			result = await helper.updateNote(note);
		} else { // Case 2: Insert Operation
			result = await helper.insertNote(note);
		}

		if (result != 0) {  // Success
			_showAlertDialog('Save Message', 'Note Saved Successfully!');
		} else {  // Failure
			_showAlertDialog('Status', 'Problem Saving Note!');
		}

	}

	void _delete() async {

		moveToLastScreen();

		// Case 1: If user is trying to delete the NEW NOTE i.e. he has come to
		// the detail page by pressing the FAB of NoteList page.
		if (note.id == null) {
			_showAlertDialog('Alert', 'No Note was deleted!');
			return;
		}

		// Case 2: User is trying to delete the old note that already has a valid ID.
		int result = await helper.deleteNote(note.id);
		if (result != 0) {
			_showAlertDialog('Delete Message', 'Note Deleted Successfully!');
		} else {
			_showAlertDialog('Alert', 'Error Occured while Deleting Note!');
		}
	}

	void _showAlertDialog(String title, String message) {

		AlertDialog alertDialog = AlertDialog(
			title: Text(title),
			content: Text(message),
		);
		showDialog(
				context: context,
				builder: (_) => alertDialog
		);
	}

}










