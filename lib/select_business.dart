import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'analyzing_business_loading.dart';

class SelectBusiness extends StatefulWidget {
  const SelectBusiness(this.ig_name, this.ig_pic_url, this.ig_access_token, {super.key});

  final String? ig_name;
  final String? ig_pic_url;
  final String? ig_access_token;

  @override
  State<SelectBusiness> createState() => _SelectBusinessState();
}

class _SelectBusinessState extends State<SelectBusiness> {

  String? ig_name = "";
  String? ig_pic_url = "";
  String? ig_access_token = "";
  List _pageslist = [];

  // vars + methods

  void _incrementCounter() {
    setState(() {

    });
  }

  Future<String> _fetchPrefs() async{

    var request = http.Request(
        'GET',
        Uri.parse(
            'https://graph.facebook.com/v14.0/me/accounts?access_token=' + ig_access_token!
        )
    );

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {

      // print(await response.stream.bytesToString());
      var responseData = await response.stream.bytesToString();
      Map valueMap = json.decode(responseData);
      print(valueMap);
      var pagerecord;
      for(pagerecord in valueMap['data']) {

        print(pagerecord['name']);
        _pageslist.add({
          'page_name': pagerecord['name'],
          'page_access_token': pagerecord['access_token'],
          'page_category': pagerecord['category'],
          'page_id': pagerecord['id']
        });

      }

    }
    else {
      print(response.reasonPhrase);
    }

    return 'true';
  }
  late Future _fetchPrefsVal = _fetchPrefs();

  @override
  void initState() {
    ig_name = widget.ig_name;
    ig_pic_url = widget.ig_pic_url;
    ig_access_token = widget.ig_access_token;
    super.initState();
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
                'Good to see you, ' + ig_name! + '!',
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

            Image.network(
                ig_pic_url!,
                width: 152,
            ),

            SizedBox(
              height: 22,
            ),

            Text(
              'Let\'s authenticate your business',
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
              'Please select one of the accounts below to proceed:',
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

            FutureBuilder(
              future: _fetchPrefsVal, // async work
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting: return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // The loading indicator
                      CircularProgressIndicator(
                        color: Colors.white,
                      ),
                      /*
                      SizedBox(
                        height: 15,
                      ),
                      // Some text
                      Text(
                        'Fetching associated pages...',
                        style: TextStyle(color: Colors.white),
                      ),

                       */
                    ],
                  );
                  default:
                    if (snapshot.hasError)
                      /*
                                      return Text(
                                          'Error!!: ${snapshot.error} ' + '\n\n' + '${snapshot.stackTrace}',
                                          style: TextStyle(color: Colors.white));

                                       */

                      return Text(
                          'Please refresh the page to view updated data',
                          style: TextStyle(color: Colors.white));
                    // return '';

                    else
                    {
                      /*
                      return Text(
                          'love',
                        style: TextStyle(color: Colors.white),
                      );

                       */
                      return SizedBox(
                        height: 250,
                        child: ListView.separated(
                              padding: const EdgeInsets.all(8),
                              itemCount: _pageslist.length,
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 20, right: 15),
                                  child: GestureDetector(
                                  // When the child is tapped, show a snackbar.
                                  onTap: () async {
                                    final _prefs = await SharedPreferences.getInstance();
                                    _prefs.setString('flow_step', '');
                                    print(_prefs.getString('ig_user_id'));
                                    print('${_pageslist[index]['page_name']}');
                                    print('${_pageslist[index]['page_id']}');
                                    print('${_pageslist[index]['page_access_token']}');
                                    print('${_pageslist[index]['page_category']}');
                                    _prefs.setString('page_name', '${_pageslist[index]['page_name']}');
                                    _prefs.setString('page_id', '${_pageslist[index]['page_id']}');
                                    _prefs.setString('page_access_token', '${_pageslist[index]['page_access_token']}');
                                    _prefs.setString('page_category', '${_pageslist[index]['page_category']}');

                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute<void>(
                                        builder: (BuildContext context) =>
                                            AnalyzingBusinessLoading(
                                                '${_pageslist[index]['page_name']}',
                                                '${_pageslist[index]['page_category']}',
                                                '${_pageslist[index]['page_access_token']}',
                                                '${_pageslist[index]['page_id']}'
                                            ),
                                      ),
                                    );

                                  },
                                  // The custom button
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                          child: Row(
                                            children: <Widget>[
                                              Text(
                                                '${_pageslist[index]['page_name']}',
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          )),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.white,
                                        size: 20.0,
                                      ),
                                    ],
                                  ),
                                  )
                                );
                              },
                              separatorBuilder: (BuildContext context, int index) => const Divider(color: Colors.white),
                            )
                      );
                    }
                }
              },
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