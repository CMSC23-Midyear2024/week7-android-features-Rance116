import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:week_7_android_features/addContacts.dart';
import 'contact.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          appBarTheme: const AppBarTheme(
              iconTheme: IconThemeData(color: Colors.white),
              color: Colors.blue,
              titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.bold)),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Colors.blue, foregroundColor: Colors.white)),
      home: const ContactList(),
    );
  }
}

class ContactList extends StatefulWidget {
  const ContactList({super.key});

  @override
  State<ContactList> createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  List<Contact>? _contacts;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() {
    FlutterContacts.addListener(() => _fetchContacts());
    _fetchContacts();
  }

  Future _fetchContacts() async {
    if (!await FlutterContacts.requestPermission(readonly: false)) {
      setState(() => _permissionDenied = true);
    } else {
      var contacts = await FlutterContacts.getContacts();
      setState(() => _contacts = contacts);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Contacts')),
      body: _body(),
      floatingActionButton: FloatingActionButton(
        onPressed: (() {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddContac(contacts: _contacts)));
        }),
        child: const Icon(Icons.contacts),
      ),
    );
  }

  Widget _body() {
    if (_permissionDenied) {
      return const Center(child: Text('Permission denied'));
    }
    if (_contacts == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
        itemCount: _contacts!.length,
        itemBuilder: (context, i) => ListTile(
            title: Text(_contacts![i].displayName),
            onTap: () {
              FlutterContacts.getContact(_contacts![i].id).then((contact) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => ContactPage(contact!)));
              });
            }));
  }
}
