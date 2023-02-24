
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';

import 'chatapalooza.dart';

class AnalyzingBusinessLoading extends StatefulWidget {
  const AnalyzingBusinessLoading(this.page_name, this.page_category, this.page_access_token, this.page_id, {super.key});

  final String? page_name;
  final String? page_category;
  final String? page_access_token;
  final String? page_id;

  @override
  State<AnalyzingBusinessLoading> createState() => _AnalyzingBusinessLoadingState();
}

class _AnalyzingBusinessLoadingState extends State<AnalyzingBusinessLoading> {

  String? page_name = "";
  String? page_category = "";
  String? page_access_token = "";
  String? page_id = "";

  // vars + methods

  void _incrementCounter() {
    setState(() {

    });
  }

  Future _fetchPrefs() async{

    var prompt = 'In a sentence, describe the characteristics and environment of a good social media photo for a company called ' + page_name! + ' operating in the ' + page_category! + ' space';
    var request = http.Request('GET', Uri.parse('https://us-central1-love-375210.cloudfunctions.net/chatgpt?prompt=' + prompt));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {

      var responseData = await response.stream.bytesToString();
      // Map valueMap = json.decode(responseData);
      print(responseData);

      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              Chatapalooza(
                  responseData?.trim(),
                  page_name,
                  page_access_token,
                  page_id
              ),
        ),
      );

    }
    else {
      print(response.reasonPhrase);
    }


  }
  late Future _fetchPrefsVal = _fetchPrefs();

  @override
  void initState() {
    page_name = widget.page_name;
    page_category = widget.page_category;
    page_access_token = widget.page_access_token;
    page_id = widget.page_id;
    super.initState();
    _fetchPrefs();
  }

  @override
  Widget build(BuildContext context) {
    MaterialColor buildMaterialColor(Color color) {
      List strengths = <double>[.05];
      Map<int, Color> swatch = {};
      final int r = color.red, g = color.green, b = color.blue;

      for (int i = 1; i < 10; i++) {
        strengths.add(0.1 * i);
      }
      strengths.forEach((strength) {
        final double ds = 0.5 - strength;
        swatch[(strength * 1000).round()] = Color.fromRGBO(
          r + ((ds < 0 ? r : (255 - r)) * ds).round(),
          g + ((ds < 0 ? g : (255 - g)) * ds).round(),
          b + ((ds < 0 ? b : (255 - b)) * ds).round(),
          1,
        );
      });
      return MaterialColor(color.value, swatch);
    }
    return Scaffold(
      backgroundColor: buildMaterialColor(Color(0xFF323232)),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            Image.asset(
              'lib/assets/co-worker-logo.png',
              width: 220,
            ),

            SizedBox(
              height: 22,
            ),

            /*
            Text(
              'love',
              style: TextStyle(color: Colors.white)
            ),

             */

            Text(
              'Analyzing account',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(
              height: 22,
            ),

            Text(
              page_name!,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(
              height: 22,
            ),

            Text(
              'Hold on while I analyze the account',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(
              height: 22,
            ),


            CircularProgressIndicator(
              color: Colors.white,
            ),


          ],
        ),
      ),
      /*
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.

       */
    );
  }
}