import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'group_name_model.dart';

class GroupNameListScreen extends StatefulWidget {
  const GroupNameListScreen({Key? key}) : super(key: key);

  @override
  State<GroupNameListScreen> createState() => _GroupNameListScreenState();
}

class _GroupNameListScreenState extends State<GroupNameListScreen> {
  var _groupNameController = TextEditingController();
  late List<GroupNameModel> _groupNameList ;
  List<dynamic> tableData = [];
  List<dynamic> groupNameTableData = [];

  @override
  void initState() {
    super.initState();
    getAllGroupName();
  }

  getAllGroupName() async {
    print('------------------> getAllGroupName');
    _groupNameList = <GroupNameModel>[];

    try {
      String url = 'http://192.168.1.6:3051/getGroupNameDetails';
      //String url = 'http://192.168.1.8:3051/tabledata';

      http.Response response = await http.get(
        Uri.parse(url)
      );

      if (response.statusCode == 200) {

        //tableData = json.decode(response.body);
        //print(tableData);

        groupNameTableData = json.decode(response.body);

        print('-------------> Received Data and Length:');
        print(groupNameTableData);
        print(groupNameTableData.length);

        for(var item in groupNameTableData){

          var _groupNameModel = GroupNameModel(
            id: item['id'],
            groupName: item['group_name_col'].toString(),
          );

          setState(() {
            _groupNameList.add(_groupNameModel);
          });
        }


      } else {
        print('--------> Exception');
        throw Exception('Failed to Receive group name details.');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  _deleteFormDialog(BuildContext context, groupNameId) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (param) {
          return AlertDialog(
            actions: <Widget>[
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color.fromRGBO(15, 53, 73, 1)),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color.fromRGBO(15, 53, 73, 1)),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
                onPressed: () async {
                  _deleteGroupName(groupNameId);
                },
                child: const Text('Delete'),
              )
            ],
            title: const Text('Are you sure you want to delete this?'),

          );
        });
  }

  _showFromDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: true,  //true-out side click dissmisses
        builder: (param) {
          return AlertDialog(
            actions: <Widget>[
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color.fromRGBO(15, 53, 73, 1)),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
                onPressed: () {
                  print('---------->cancel invoked');
                  Navigator.pop(context);
                  _groupNameController.clear();
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color.fromRGBO(15, 53, 73, 1)),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
                onPressed: () async{
                  _save();
                },
                child: Text('Save'),
              )
            ],
            title: Text('Enter Group Name'),
            content: SingleChildScrollView(
              child: Column(children: <Widget>[
                TextField(
                  controller: _groupNameController,
                  decoration: InputDecoration(
                    hintText: 'Enter group name',),
                ),
              ]),
            ),
          );
        });
  }

  _editCategory(BuildContext context, groupNameId) async{

    print(groupNameId);

    // Populate value - group name
    for(var item in _groupNameList){
      print(item.id);
      print(item.groupName);

      if(item.id == groupNameId){
        print('-----------> Row found: $item.groupName');
        setState(() {
          _groupNameController.text = item.groupName;
        });
      }
    }

    _editFromDialog(context, groupNameId);
  }

  _editFromDialog(BuildContext context, groupNameId) {
    return showDialog(
        context: context,
        barrierDismissible: true,  //true-out side click dissmisses
        builder: (param) {
          return AlertDialog(
            actions: <Widget>[
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color.fromRGBO(15, 53, 73, 1)),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
                onPressed: () {
                  print('---------->Cancel Clicked');
                  Navigator.pop(context);
                  _groupNameController.clear();
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color.fromRGBO(15, 53, 73, 1)),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
                onPressed: () async{
                  print('---------->Update Clicked');
                  print('Group name: ${_groupNameController.text}');
                  _update(groupNameId);
                },
                child: Text('Update'),
              )
            ],
            title: Text('Edit Group Name'),
            content: SingleChildScrollView(
              child: Column(children: <Widget>[
                TextField(
                  controller: _groupNameController,
                  decoration: InputDecoration(
                    hintText: 'Enter group name',),
                ),
              ]),
            ),
          );
        });
  }

  void _save() async {
    print('---------->save Clicked');
    print('---------------> Group Name: $_groupNameController.text');

    String url = 'http://192.168.1.6:3051/api/storeGroupNameDetails';

    var match = {
      "group_name_col": _groupNameController.text,
    };

    var response = await http.post(Uri.parse('${url}'),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body: match,
        encoding: Encoding.getByName("utf-8"));

    if (response.statusCode == 200) {
      print('---------------> Successfully saved.');
      _showSuccessSnackBar(context, 'Successfully saved.');
    } else {
      print('---------------> Failed to save.');
      _showSuccessSnackBar(context, 'Failed to save.');
      throw Exception('Failed to store group name details.');
    }

    Navigator.pop(context);
    getAllGroupName();

    _groupNameController.clear();
  }

  void _update(int groupNameId) async {
    print('---------------> Group Name: ${_groupNameController.text}');
    print('---------------> Group Name id: $groupNameId');

    String tmpGroupNameCol = _groupNameController.text;

    //String url = 'http://192.168.1.8:3051';
    // String url = 'http://localhost:3051/api/loginCheck?name=test&passwd=check';
    //final response = await http.get(Uri.parse('${url}/api/loginCheck?name=test&passwd=check'));

    String url = 'http://192.168.1.6:3051/api/updateGroupName?id=$groupNameId&group_name_col=$tmpGroupNameCol';

    print('-----------> Url: $url');

    var response = await http.get(Uri.parse(url));

    if(response.statusCode == 200){
      print('---------------> Successfully updated.');
      _showSuccessSnackBar(context, 'Successfully updated.');
      Navigator.pop(context);
      setState(() {
        getAllGroupName();
      });
    }else{
      print('---------------> Failed to delete.');
      _showSuccessSnackBar(context, 'Failed to delete.');
      Navigator.pop(context);
    }

    _groupNameController.clear();
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(new SnackBar(content: new Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Group Name List',
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: _groupNameList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
            child: Card(
              elevation: 8.0,
              child: ListTile(
                leading: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    print('---------------> Edit');
                    _editCategory(context, _groupNameList[index].id);
                  },
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(_groupNameList[index].groupName),
                    IconButton(
                      onPressed: () {
                        print('---------------> Delete');
                        _deleteFormDialog(context, _groupNameList[index].id);
                      },
                      icon: Icon(Icons.delete, color: Colors.red,),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromRGBO(15, 53, 73, 1),
        foregroundColor: Colors.white,
        onPressed: () {
          print('---------->FAB Clicked');
          _showFromDialog(context);
        },
        child: Icon(
          Icons.add,
        ),
      ),
    );
  }

  void _deleteGroupName(groupNameId) async{
    print('---------->Delete Clicked: id: $groupNameTableData');

    //String url = 'http://192.168.1.8:3051';
    // String url = 'http://localhost:3051/api/loginCheck?name=test&passwd=check';
    //final response = await http.get(Uri.parse('${url}/api/loginCheck?name=test&passwd=check'));

    String url = 'http://192.168.1.6:3051/api/deleteGroupName?id=$groupNameId';

    print('-----------> Url: $url');

    var response = await http.get(Uri.parse(url));

    if(response.statusCode == 200){
      print('---------------> Successfully deleted.');
      _showSuccessSnackBar(context, 'Successfully deleted.');
      Navigator.pop(context);
      setState(() {
        _groupNameList.removeWhere((item) => item.id == groupNameId);
      });
      // ###
      //getAllGroupName();
    }else{
      print('---------------> Failed to delete.');
      _showSuccessSnackBar(context, 'Failed to delete.');
      Navigator.pop(context);
    }
  }
}
