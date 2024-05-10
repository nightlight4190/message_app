// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:message_app/pages/chat.dart';
import 'package:message_app/pages/people.dart';
import 'package:message_app/pages/stories.dart';

import '../constants.dart';

class ChatHome extends StatefulWidget {
  const ChatHome({super.key});

  @override
  State<ChatHome> createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> {
  int _selectedIndex = 0;

  void _onTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 212, 212, 212),
      appBar: AppBar(
        backgroundColor: pColor,
        foregroundColor: sColor,
        title: Text("Chats"),
        centerTitle: true,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: iconColor),
            ),
            child: Center(
              child: IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: sColor,
                  ),
                  onPressed: () {}),
            ),
          )
        ],
      ),
      drawer: Drawer(),
      body: [
        Chat(),
        PeopleChat(),
        StoriesChat(),
      ][_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: pColor,
        currentIndex: _selectedIndex,
        onTap: _onTapped,
        items: [
          BottomNavigationBarItem(
            label: "Chat",
            icon: Icon(CupertinoIcons.chat_bubble),
          ),
          BottomNavigationBarItem(
            label: "People",
            icon: Icon(CupertinoIcons.person),
          ),
          BottomNavigationBarItem(
            label: "Stories",
            icon: Icon(
              Icons.web_stories_outlined,
            ),
          ),
        ],
      ),
    );
  }
}
