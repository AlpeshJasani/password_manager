import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import '../database/db_helper.dart';
import '../models/password.dart';
import 'add_edit_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Password> passwords = [];
  List<Password> filteredPasswords = [];
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fetchPasswords();
  }

  void _fetchPasswords() async {
    final dbHelper = DBHelper();
    final data = await dbHelper.getPasswords();
    setState(() {
      passwords = data;
      filteredPasswords = data;
    });
  }

  // Permission check and export function
  void _exportPasswords() async {
    // Check storage permission
    var status = await Permission.storage.status;
    if (status.isDenied) {
      // Request permission if denied
      if (await Permission.storage.request().isGranted) {
        _performExport(); // Proceed with export if granted
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Storage permission is required to export passwords.')),
        );
      }
    } else if (status.isPermanentlyDenied) {
      // If permanently denied, suggest enabling from settings
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enable storage permission from app settings to export passwords.'),
          action: SnackBarAction(
            label: 'Open Settings',
            onPressed: () => openAppSettings(),
          ),
        ),
      );
    } else {
      // If already granted, proceed with export
      _performExport();
    }
  }

  // Perform the actual export
  void _performExport() async {
    try {
      // Use FilePicker to get the directory for saving the file
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory == null) {
        // Handle the case where the user cancels the directory selection
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export cancelled')),
        );
        return;
      }

      // Construct the full file path in the selected directory
      final filePath = path.join(selectedDirectory, 'passwords_export.txt');

      // Create the content to be exported (a simple text representation of passwords)
      String fileContent = passwords
          .map((password) =>
      "Name: ${password.name}, Username: ${password.username}, Password: ${password.password}, Note: ${password.note}")
          .join('\n');

      // Write the content to the file
      File file = File(filePath);
      await file.writeAsString(fileContent);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords exported successfully!')),
      );
    } catch (e) {
      // Handle any errors during the export
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting passwords: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (searchFocusNode.hasFocus) {
          searchFocusNode.unfocus();
          searchController.clear();
          setState(() {
            filteredPasswords = passwords;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Password Manager'),
          actions: [
            IconButton(
              icon: Icon(Icons.download),
              onPressed: _exportPasswords,  // Trigger export
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                focusNode: searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'Search by Name or Username',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      searchController.clear();
                      setState(() {
                        filteredPasswords = passwords;
                      });
                    },
                  )
                      : null,
                ),
                onChanged: (query) {
                  setState(() {
                    filteredPasswords = passwords
                        .where((password) =>
                    password.name.toLowerCase().contains(query.toLowerCase()) ||
                        password.username.toLowerCase().contains(query.toLowerCase()))
                        .toList();
                  });
                },
              ),
            ),
            Expanded(
              child: filteredPasswords.isEmpty
                  ? Center(
                child: Text(
                  'No passwords found',
                  style: TextStyle(color: Colors.white70),
                ),
              )
                  : ListView.builder(
                itemCount: filteredPasswords.length,
                padding: EdgeInsets.only(bottom: 56),  // padding bellow the list
                itemBuilder: (context, index) {
                  final password = filteredPasswords[index];
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                      title: Text(
                        password.name,
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        password.username,
                        style: TextStyle(color: Colors.white70),
                      ),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddEditScreen(password: password),
                          ),
                        );
                        if (result != null) _fetchPasswords();
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddEditScreen()),
            );
            if (result != null) _fetchPasswords();
          },
        ),
      ),
    );
  }
}
