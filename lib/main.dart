import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //text in top bar of app
      title: 'Check On Them - App',
      //content under the title in the main area
      // home: SeeContactsButton(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Check On Them - App'),
          backgroundColor: Colors.amber,
        ),
        body: Center(
          child: SeeContactsButton(),
        ),
      ),
    );
  }
}

class SeeContactsButton  extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
        onPressed: () async {
          //request permission via async function and store response in appropriate object
          final PermissionStatus permissionStatus = await _getPermission();
          //check if permission status is granted
          if(permissionStatus == PermissionStatus.granted){
            //access contacts here
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ContactsPage())
            );
          }
          //if permission is not granted, then show a dialog asking the user to grant access
          else{
            showDialog(
                context: context,
                builder: (BuildContext context) => CupertinoAlertDialog(
                  title: Text('Permission error'),
                  content: Text('Please grant contact access permission privileges to the "Check On Them - App" in the system settings'),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      child: Text('OK'),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                )
            );
          }
        },
      // child: Container(child: Text('See Contacts')),
      child: Text('Hello!\n\nReady to reconnect with the people in your contacts?\n\n\nThen tap anywhere on the screen to begin!', textScaleFactor: 3.0),
      padding: const EdgeInsets.all(16.0),
      color: Colors.amber,
    );
  }

  //future is an object that will be populated or available later
  Future<PermissionStatus> _getPermission() async {
    //specify and store the type of permission we expect to store in our permission object
    final PermissionStatus permission = await Permission.contacts.status;
    //if the permission is neither granted or denied
    if(permission != PermissionStatus.granted){
      //map the permission to it corresponding status
      final Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.contacts].request();
      //return the specific status for this particular permission, unless its null
      return permissionStatus[Permission.contacts] ??
          //then return a denied status instead;
        PermissionStatus.denied;
    }else{
      return permission;
    }
  }
}

class ContactsPage extends StatefulWidget {

  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  late Iterable<Contact> _contacts;

  @override
  void initState(){
    getContacts();
    super.initState();
  }

  Future<void> getContacts() async{
    final Iterable<Contact> contacts = await ContactsService.getContacts();
    setState(() {
      _contacts = contacts;
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: (Text('Contacts')),
      ),
      body: _contacts != null
      //if we have contacts make the body a list view
      ? ListView.builder(
        //itemCount is zero if _contacts is null
        itemCount: _contacts?.length ?? 0,
        itemBuilder: (BuildContext context, int index){
          Contact contact = _contacts.elementAt(index);
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 18),
            leading: (contact.avatar != null && contact.avatar!.isNotEmpty)
              ? CircleAvatar(
                backgroundImage: MemoryImage(contact.avatar!),
              )
              : CircleAvatar(
                child: Text(contact.initials()),
                backgroundColor: Theme.of(context).accentColor,
              ),
            title: Text(contact.displayName ?? ''),
          );
        },
      )
    : Center(child: const CircularProgressIndicator()),
    );
  }

}

