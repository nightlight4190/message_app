// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:message_app/constants.dart';
import 'package:http/http.dart' as http;
import 'package:message_app/pages/view_page/chat_msg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckSender extends StatefulWidget {
  const CheckSender({super.key});

  @override
  State<CheckSender> createState() => _CheckSenderState();
}

class _CheckSenderState extends State<CheckSender> {
  TextEditingController nameController = TextEditingController();
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  bool isLoading = true;

  Future savePersoInfo(String name, int id) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString("sender_name", name);
    await prefs.setInt("sender_id", id);
    print("$name and $id saved to local storage");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: pColor,
        foregroundColor: sColor,
        title: Text("Group Messaging"),
        centerTitle: true,
      ),
      body: Form(
        key: formkey,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Enter your name to join :",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * .8,
                  child: TextFormField(
                    validator: (inputText) {
                      if (inputText == null) {
                        return "Enter something";
                      }
                      if (!inputText.contains(" ")) {
                        return "Enter your full name ";
                      }

                      if (inputText.isEmpty) {
                        return " Enter something";
                      }
                      return null;
                    },
                    controller: nameController,
                    cursorColor: pColor,
                    decoration: InputDecoration(
                      focusColor: pColor,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                TextButton(
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(pColor),
                      foregroundColor: WidgetStatePropertyAll(sColor)),
                  onPressed: isLoading
                      ? () async {
                          print("button pressed");
                          if (formkey.currentState!.validate()) {
                            try {
                              setState(() {
                                isLoading = true;
                              });
                              var response = await http.post(
                                Uri.parse("$ip/peoples/new"),
                                headers: {"Content-Type": "application/json"},
                                body: jsonEncode(
                                  {"name": nameController.text},
                                ),
                              );
                              if (response.statusCode == 200) {
                                print(response.body);
                                var decoded = jsonDecode(response.body);
                                await savePersoInfo(
                                  decoded['data']['person']['name'],
                                  decoded['data']['person']['id'],
                                );
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => ChatMsg(
                                      senderId: decoded['data']['person']['id'],
                                      // senderName: decoded['data']
                                      //     ['person']['name'],
                                    ),
                                  ),
                                );
                              } else {
                                throw Exception(
                                    "Invalid response : ${response.body}");
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                ),
                              );
                            }
                          } else {
                            print("Invalid");
                          }
                        }
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: isLoading
                        ? Text(
                            "Continue",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : CircularProgressIndicator(
                            color: Colors.teal,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
