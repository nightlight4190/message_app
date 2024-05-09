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
                child: FutureBuilder(
                    future: http
                        .get(Uri.parse("http://192.168.10.71:3000/messages")),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text(
                          "Error: ${snapshot.error}",
                          style: TextStyle(color: Colors.red),
                        );
                      } else if (snapshot.hasData) {
                        var decodedResponse = jsonDecode(snapshot.data!.body);
                        if (decodedResponse['status'] == 'success') {
                          List message = decodedResponse['data']['messages'];
                          print(message);
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: message.reversed
                                .map((e) =>
                                    MessageContainer(message: e.toString()))
                                .toList(),
                          );
                        } else {
                          return Text("Something went wrong");
                        }
                      } else {
                        return CircularProgressIndicator();
                      }
                    }),
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
}

class MessageContainer extends StatelessWidget {
  String message;
  MessageContainer({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}
