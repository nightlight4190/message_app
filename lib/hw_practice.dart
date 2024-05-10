import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HwPractice extends StatefulWidget {
  const HwPractice({super.key});

  @override
  State<HwPractice> createState() => _HwPracticeState();
}

class _HwPracticeState extends State<HwPractice> {
  final TextEditingController _messageController = TextEditingController();
  bool _sendingRequest = false;
  List _messages = [];

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    setState(() {
      _sendingRequest = true;
    });
    var response =
        await http.get(Uri.parse("http://192.168.10.71:3000/messages"));
    setState(() {
      _sendingRequest = false;
    });
    var decodedResponse = jsonDecode(response.body);
    if (decodedResponse['status'] == 'success') {
      setState(() {
        _messages = decodedResponse['data']['messages'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(decodedResponse['data']['message'])));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Messaging App Hw"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: _messages.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: _messages.reversed
                            .map((e) => MessageContainer(
                                  message: e.toString(),
                                  onLongPress: () => _showDeleteDialog(e),
                                  onDoubleTap: () => _showEditDialog(e),
                                ))
                            .toList(),
                      ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 60,
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Enter message here...",
                      filled: true,
                      fillColor: const Color.fromARGB(255, 231, 230, 230),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  onPressed: () async {
                    setState(() {
                      _sendingRequest = true;
                    });
                    var response = await http.post(
                        Uri.parse("http://192.168.10.71:3000/messages"),
                        headers: {
                          "Content-Type": "application/json",
                        },
                        body: jsonEncode({"message": _messageController.text}));
                    _messageController.clear();
                    var decodedResponse = jsonDecode(response.body);
                    if (decodedResponse['status'] != 'success') {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(decodedResponse['data']['message'])));
                    }
                    setState(() {
                      _sendingRequest = false;
                    });
                    _fetchMessages();
                  },
                  icon: !_sendingRequest
                      ? Icon(Icons.send, color: Colors.blue)
                      : CupertinoActivityIndicator(),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Message"),
        content: Text("Are you sure you want to delete this message?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              var response = await http.delete(
                Uri.parse("http://192.168.10.71:3000/messages/$message"),
              );
              var decodedResponse = jsonDecode(response.body);
              if (decodedResponse['status'] != 'success') {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(decodedResponse['data']['message'])));
              } else {
                _fetchMessages();
              }
            },
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(String message) {
    final TextEditingController _editController =
        TextEditingController(text: message);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Message"),
        content: TextField(
          controller: _editController,
          decoration: InputDecoration(
            hintText: "Enter new message...",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              var response = await http.put(
                Uri.parse("http://192.168.10.71:3000/messages/$message"),
                headers: {
                  "Content-Type": "application/json",
                },
                body: jsonEncode({"message": _editController.text}),
              );
              var decodedResponse = jsonDecode(response.body);
              if (decodedResponse['status'] != 'success') {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(decodedResponse['data']['message'])));
              } else {
                _fetchMessages();
              }
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }
}

class MessageContainer extends StatelessWidget {
  String message;
  final VoidCallback onLongPress;
  final VoidCallback onDoubleTap;

  MessageContainer({
    super.key,
    required this.message,
    required this.onLongPress,
    required this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      onDoubleTap: onDoubleTap,
      child: Row(
        children: [
          Expanded(
            child: Container(),
          ),
          Container(
            alignment: Alignment.centerRight,
            margin: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                message,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
