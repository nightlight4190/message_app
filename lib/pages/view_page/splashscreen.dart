import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_msg.dart';
import 'check_sender.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> checkIfUserIdExists() async {
    var prefs = await SharedPreferences.getInstance();
    int? savedId = prefs.getInt("sender_id");
    if (savedId != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ChatMsg(senderId: savedId),
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
    checkIfUserIdExists();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Group Messaging App.",
              style: TextStyle(
                fontSize: 20,
              ),
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
