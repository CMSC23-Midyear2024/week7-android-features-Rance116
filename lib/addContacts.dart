import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/properties/email.dart';
import 'package:flutter_contacts/properties/phone.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:week_7_android_features/main.dart';

class AddContac extends StatefulWidget {
  final List<Contact>? contacts;
  const AddContac({required this.contacts, super.key});

  @override
  State<AddContac> createState() => _AddContac();
}

class _AddContac extends State<AddContac> {
  late String _fname;
  String? _lname = null;
  late String _number;
  String? _email = null;
  TextEditingController _fnameCon = TextEditingController();
  TextEditingController _lnameCon = TextEditingController();
  TextEditingController _numCon = TextEditingController();
  TextEditingController _emailCon = TextEditingController();
  final GlobalKey<FormState> addcontactkey = GlobalKey<FormState>();

  Permission permission = Permission.camera;
  PermissionStatus permissionStatus = PermissionStatus.denied;
  File? imageFile;

  @override
  void initState() {
    super.initState();

    _listenForPermissionStatus();
  }

  void _listenForPermissionStatus() async {
    final status = await permission.status;
    setState(() => permissionStatus = status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Contact"),
      ),
      body: SingleChildScrollView(
          child: Form(
        key: addcontactkey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.all(15),
              child: imageFile == null
                  ? TextButton(
                      onPressed: () async {
                        if (permissionStatus == PermissionStatus.granted) {
                          final image = await ImagePicker()
                              .pickImage(source: ImageSource.camera);

                          setState(() {
                            imageFile = image == null ? null : File(image.path);
                          });
                        } else {
                          requestPermission();
                        }
                      },
                      child: Icon(Icons.camera_alt))
                  : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(
                        width: 120,
                        height: 120,
                        child: ClipOval(
                          child: Image.file(imageFile!, fit: BoxFit.fill),
                        ),
                      ),
                      TextButton(
                          onPressed: () async {
                            if (permissionStatus == PermissionStatus.granted) {
                              final image = await ImagePicker()
                                  .pickImage(source: ImageSource.camera);

                              setState(() {
                                imageFile =
                                    image == null ? null : File(image.path);
                              });
                            } else {
                              requestPermission();
                            }
                          },
                          child: Icon(Icons.camera_alt))
                    ]),
            ),
            Padding(
              padding: EdgeInsets.all(15),
              child: TextFormField(
                controller: _fnameCon,
                onSaved: (val) {
                  setState(() {
                    _fname = val!;
                  });
                },
                validator: (val) {
                  if (val == null || val.isEmpty)
                    return "please enter first name";
                  return null;
                },
                decoration: InputDecoration(label: Text("First Name")),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(15),
              child: TextFormField(
                controller: _lnameCon,
                onSaved: (val) {
                  setState(() {
                    _lname = val!;
                  });
                },
                decoration: InputDecoration(label: Text("Last Name")),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(15),
              child: TextFormField(
                keyboardType: TextInputType.number,
                controller: _numCon,
                onSaved: (val) {
                  setState(() {
                    _number = val!;
                  });
                },
                validator: (val) {
                  if (val == null || val.isEmpty || int.tryParse(val) == null)
                    return "please enter valid phone number";
                  return null;
                },
                decoration: InputDecoration(label: Text("Phone Number")),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(15),
              child: TextFormField(
                controller: _emailCon,
                onSaved: (val) {
                  setState(() {
                    _email = val!;
                  });
                },
                decoration: InputDecoration(label: Text("Email")),
              ),
            ),
            OutlinedButton(
                onPressed: () async {
                  if (addcontactkey.currentState!.validate()) {
                    addcontactkey.currentState!.save();
                    Contact newContact = Contact()
                      ..name.first = _fname
                      ..name.last = _lname!
                      ..phones = [Phone(_number)]
                      ..emails = [Email(_email!)];
                    await newContact.insert();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => MyApp()));
                  }
                },
                child: Text("Add Contact"))
          ],
        ),
      )),
    );
  }

  Future<void> requestPermission() async {
    final status = await permission.request();

    setState(() {
      print(status);
      permissionStatus = status;
      print(permissionStatus);
    });
  }
}
