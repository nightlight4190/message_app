import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:message_app/pages/view_page/chat_msg.dart';
import 'package:message_app/pages/view_page/check_sender.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> checkIfUserIsExists() async {
    var prefs = await SharedPreferences.getInstance();
    int? savedId = prefs.getInt("sender_Id");
    // String? savedName = prefs.getString("sender_name");
    if (savedId != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ChatMsg(
            senderId: savedId,
            // senderName: savedName,
          ),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => CheckSender(),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    checkIfUserIsExists();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Group Messaging App.",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 20,
            ),
            CupertinoActivityIndicator(
              radius: 15,
            ),
          ],
        ),
      ),
    );
  }
}
