// ignore_for_file: sized_box_for_whitespace

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../constants.dart';

class MsgContainer extends StatefulWidget {
  Map<String, dynamic> msg;
  Function onMessageDeletedOrEdited;
  MsgContainer({
    super.key,
    required this.msg,
    required this.onMessageDeletedOrEdited,
  });

  @override
  State<MsgContainer> createState() => _MsgContainerState();
}

class _MsgContainerState extends State<MsgContainer> {
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textEditingController.text = widget.msg['message'];
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.5,
          alignment: Alignment.centerRight,
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Container(
            decoration: BoxDecoration(
              color: pColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: InkWell(
              onDoubleTap: () {
                editDialog(context);
              },
              onLongPress: () {
                deleteDialog(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  textAlign: TextAlign.left,
                  widget.msg['message'],
                  softWrap: true,
                  maxLines: 5,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<dynamic> deleteDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) => Container(
              height: 100,
              width: 300,
              child: AlertDialog(
                title: Text(
                  "Do you want to delete this message?",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        style: ButtonStyle(
                            foregroundColor: WidgetStatePropertyAll(sColor),
                            backgroundColor: WidgetStatePropertyAll(pColor)),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("No"),
                      ),
                      TextButton(
                        style: ButtonStyle(
                            foregroundColor: WidgetStatePropertyAll(sColor),
                            backgroundColor: WidgetStatePropertyAll(pColor)),
                        onPressed: () async {
                          var response = await http.delete(
                              Uri.parse('$ip/messages/${widget.msg["id"]}'));
                          if (response.statusCode == 200) {
                            var decoded = jsonDecode(response.body);
                            if (decoded['status'] == 'fail') {
                              print(decoded['data']);
                            } else {
                              widget.onMessageDeletedOrEdited();
                              Navigator.of(context).pop();
                            }
                          }
                        },
                        child: Text("Yes"),
                      ),
                    ],
                  ),
                ],
              ),
            ));
  }

  Future<dynamic> editDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return Container(
            height: 100,
            width: 300,
            child: AlertDialog(
              title: Text(
                "Edit message",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: TextField(
                controller: textEditingController,
                cursorColor: pColor,
                decoration: InputDecoration(
                  hintText: textEditingController.text,
                  filled: true,
                  fillColor: textFieldBg,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      style: ButtonStyle(
                          foregroundColor: WidgetStatePropertyAll(sColor),
                          backgroundColor: WidgetStatePropertyAll(pColor)),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Cancel"),
                    ),
                    TextButton(
                      style: ButtonStyle(
                          foregroundColor: WidgetStatePropertyAll(sColor),
                          backgroundColor: WidgetStatePropertyAll(pColor)),
                      onPressed: () async {
                        var response = await http.put(
                          Uri.parse('$ip/messages/${widget.msg["id"]}'),
                          headers: {"Content-Type": "application/json"},
                          body: jsonEncode(
                              {"message": textEditingController.text}),
                        );
                        if (response.statusCode == 200) {
                          var decoded = jsonDecode(response.body);
                          if (decoded['status'] == 'fail') {
                            print(decoded['data']);
                            return;
                          } else {
                            widget.onMessageDeletedOrEdited();
                            Navigator.of(context).pop();
                          }
                        }
                      },
                      child: Text("Edit"),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }
}
