import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import '../database/db_helper.dart';
import '../models/password.dart';

class AddEditScreen extends StatefulWidget {
  final Password? password;

  AddEditScreen({this.password});

  @override
  _AddEditScreenState createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String username = '';
  String password = '';
  String note = '';
  bool isEditable = false;
  bool _isPasswordVisible = false; // Added state to toggle password visibility

  @override
  void initState() {
    super.initState();
    if (widget.password != null) {
      name = widget.password!.name;
      username = widget.password!.username;
      password = widget.password!.password;
      note = widget.password!.note;
    }
  }

  void _savePassword() async {
    if (_formKey.currentState!.validate()) {
      final dbHelper = DBHelper();
      final newPassword = Password(
        id: widget.password?.id,
        name: name,
        username: username,
        password: password,
        note: note,
      );

      if (widget.password == null) {
        await dbHelper.insertPassword(newPassword);
      } else {
        await dbHelper.updatePassword(newPassword);
      }

      Navigator.pop(context, true);
    }
  }

  void _deletePassword() async {
    final dbHelper = DBHelper();
    if (widget.password != null) {
      await dbHelper.deletePassword(widget.password!.id!);
    }
    Navigator.pop(context, true); // Close the screen after deletion.
  }

  void _copyToClipboard(String value, String fieldName) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$fieldName copied to clipboard')),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Password', style: TextStyle(color: Colors.red)),
        content: Text('Are you sure you want to delete this password?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close dialog.
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog.
              _deletePassword(); // Delete password.
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNewPassword = widget.password == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isNewPassword ? 'Add Password' : 'Password Details'),
        backgroundColor: Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Add padding before the name field
              Padding(
                padding: const EdgeInsets.only(top: 30), // Adjust top padding here
                child: _buildTextField(
                  label: 'Name',
                  initialValue: name,
                  isEditable: isEditable || isNewPassword,
                  onChanged: (value) => name = value,
                  validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
                ),
              ),
              _buildTextFieldWithCopy(
                label: 'Username',
                initialValue: username,
                isEditable: isEditable || isNewPassword,
                onChanged: (value) => username = value,
                onCopy: () => _copyToClipboard(username, "Username"),
              ),
              _buildTextFieldWithCopy(
                label: 'Password',
                initialValue: password,
                isEditable: isEditable || isNewPassword,
                onChanged: (value) => password = value,
                onCopy: () => _copyToClipboard(password, "Password"),
              ),
              _buildTextField(
                label: 'Note',
                initialValue: note,
                isEditable: isEditable || isNewPassword,
                onChanged: (value) => note = value,
              ),
              SizedBox(height: 20),
              if (isNewPassword)
                ElevatedButton(
                  onPressed: _savePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent, // Button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  ),
                  child: Text('Save'),
                )
              else if (isEditable)
                ElevatedButton(
                  onPressed: _savePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent, // Button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  ),
                  child: Text('Save Changes'),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isEditable = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                      ),
                      child: Text('Edit',
                        style: TextStyle(fontSize: 16,),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _showDeleteConfirmation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                      ),
                      child: Text('Delete',
                        style: TextStyle(fontSize: 16,),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required bool isEditable,
    required Function(String) onChanged,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        initialValue: initialValue,
        enabled: isEditable,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.black26,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
        ),
        style: TextStyle(color: Colors.white),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  Widget _buildTextFieldWithCopy({
    required String label,
    required String initialValue,
    required bool isEditable,
    required Function(String) onChanged,
    required VoidCallback onCopy,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              initialValue: initialValue,
              enabled: isEditable,
              obscureText: label == 'Password' && !_isPasswordVisible, // Toggle visibility
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
              ),
              style: TextStyle(color: Colors.white),
              onChanged: onChanged,
            ),
          ),
          if (label == 'Password') // Eye icon only for password fields
            IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          IconButton(
            icon: Icon(Icons.copy, color: Colors.white),
            onPressed: onCopy,
          ),
        ],
      ),
    );
  }
}
