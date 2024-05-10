// ignore_for_file: sized_box_for_whitespace, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../resources/components/chat_mag_appbar_icon.dart';
import '../../resources/components/msg_container.dart';
import '../../constants.dart';

class ChatMsg extends StatefulWidget {
  const ChatMsg({super.key});

  @override
  State<ChatMsg> createState() => _ChatMsgState();
}

class _ChatMsgState extends State<ChatMsg> {
  TextEditingController textEditingController = TextEditingController();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 212, 212, 212),
      appBar: AppBar(
        backgroundColor: pColor,
        foregroundColor: sColor,
        title: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage("${randomImgUrl}1"),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 4.0, bottom: 2),
                child: Container(
                  height: 13,
                  width: 13,
                  decoration: BoxDecoration(
                    border: Border.all(color: sColor),
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          title: Text(
            "John",
            style: TextStyle(
              fontSize: 14,
              color: sColor,
            ),
          ),
          subtitle: Text(
            "Active Now",
            style: TextStyle(color: iconColor, fontSize: 11),
          ),
          trailing: Container(
            width: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  child: ChatMsgAppBarIcon(
                      name: Icon(
                    CupertinoIcons.phone,
                    color: Colors.white,
                  )),
                ),
                InkWell(
                  child: ChatMsgAppBarIcon(
                    name: Icon(
                      CupertinoIcons.video_camera,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
                InkWell(
                  child: ChatMsgAppBarIcon(
                    name: Icon(
                      CupertinoIcons.bell,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: SingleChildScrollView(
                reverse: true,
                child: FutureBuilder(
                    future: http.get(Uri.parse("$ip/messages")),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "Error: ${snapshot.error}",
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      } else if (snapshot.hasData) {
                        var decodedResponse = jsonDecode(snapshot.data!.body);
                        if (decodedResponse['status'] == 'success') {
                          List messages = decodedResponse['data'];
                          return Column(
                            children: messages
                                .map(
                                  (e) => MsgContainer(
                                    msg: e,
                                    onMessageDeletedOrEdited: () {
                                      setState(() {});
                                    },
                                  ),
                                )
                                .toList(),
                          );
                        } else {
                          return Text("Something went wrong");
                        }
                      } else {
                        // loading condition
                        return Center(child: CircularProgressIndicator());
                      }
                    }),
              ),
            ),
            Container(
              height: 60,
              width: MediaQuery.of(context).size.width,
              child: TextField(
                cursorColor: pColor,
                controller: textEditingController,
                decoration: InputDecoration(
                  hintText: "Enter message here...",
                  hintStyle: TextStyle(
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 231, 230, 230),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: IconButton(
                      icon: isLoading
                          ? CupertinoActivityIndicator()
                          : Icon(
                              Icons.send,
                              color: pColor,
                            ),
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        var response = await http.post(
                          Uri.parse('$ip/messages'),
                          headers: {"Content-Type": "application/json"},
                          body: jsonEncode(
                              {"message": textEditingController.text}),
                        );
                        textEditingController.clear();
                        var decodedResponse = jsonDecode(response.body);
                        if (decodedResponse['status'] != 'success') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                backgroundColor: pColor,
                                content:
                                    Text(decodedResponse['data']['message'])),
                          );
                        }
                        setState(() {
                          isLoading = false;
                        });
                      },
                      
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
