import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String id;
  final db = Firestore.instance;

  String _selectedDate = 'pick date';
  String _selectedTime = 'pick time';

  Future _pickDate() async{
    DateTime datepick = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().add(Duration(days: -365)),
      lastDate: DateTime.now().add(Duration(days: 365)));
      if(datepick != null) setState((){
        _selectedDate = datepick.toString();
      }
    );
  }

  Future _pickTime()async{
    TimeOfDay timepick = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now()
    );
    if (timepick != null){
      setState(() {
        _selectedTime = timepick.toString();
      });
    }
  }

  TextEditingController todo = TextEditingController();
  TextEditingController date = TextEditingController();
  TextEditingController time = TextEditingController();
  

  ScrollController _sc = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Firebase Demo"),
      ),
      body: ListView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Task',
                        fillColor: Colors.grey[300],
                        filled: true,
                      ),
                      controller: todo,
                    ),
                  ),
                ],
              ),

      FlatButton(
        onPressed:_pickDate ,
            child: Row(
            children: <Widget>[
            Icon(Icons.date_range,size: 30,),
            Text(
            'pick date',
            style:TextStyle(fontSize: 14) ,)
          ],
        ),
      ),

        FlatButton(
        onPressed:_pickTime ,
            child: Row(
            children: <Widget>[
            Icon(Icons.access_time,size: 30,),
            Text(
            'pick time',
            style:TextStyle(fontSize: 14) ,)
          ],
        ),
      ),
        
        
      

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                    color: Colors.blue,
                    onPressed: createData,
                    child: Text("Submit"),
                  )
                ],
              ),
              Container(
                child: ListView(
                  controller: _sc,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  padding: EdgeInsets.all(8.0),
                  children: <Widget>[
                    StreamBuilder<QuerySnapshot>(
                      stream: db.collection('test').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Column(
                              children: snapshot.data.documents
                                  .map((doc) => buildItem(doc))
                                  .toList());
                        } else {
                          return SizedBox();
                        }
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void createData() async {
    final task = todo.text;
    final dt = _selectedDate;
    final times = _selectedTime;

    DocumentReference ref = await db.collection('test').add({'todo': '$task', 'Date': '$dt', 'Time':'$times' });
    setState(() => id = ref.documentID);
    print(ref.documentID);
    clearController();
  }

  void updateData(DocumentSnapshot doc) async {
    final task = todo.text;
    final _selectedDate = date.text;
    await db
        .collection('test')
        .document(doc.documentID)
        .updateData({'todo': '$task', 'Date': '$_selectedDate', 'Time':'$_selectedTime'});
  }

  void deleteData(DocumentSnapshot doc) async {
    await db.collection('test').document(doc.documentID).delete();
    setState(() => id = null);
  }

  void clearController(){
    setState(() {
     todo.text="";
     date.text=""; 
    });
  }

  Card buildItem(DocumentSnapshot doc) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Todo: ${doc.data['todo']}',
              
              style: TextStyle(fontSize: 24),
            ),
            Text(
              'Date: ${doc.data['Date']}',
              
              style: TextStyle(fontSize: 18),
            ),
               Text(
              'Time: ${doc.data['Time']}',
              
              style: TextStyle(fontSize: 16),
            ),

            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  onPressed: () => updateData(doc),
                  child: Text('Update',
                      style: TextStyle(color: Colors.white)),
                  color: Colors.green,
                ),
                SizedBox(width: 8),
                FlatButton(
                  color: Colors.red,
                  onPressed: () => deleteData(doc),
                  child: Text('Delete'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
