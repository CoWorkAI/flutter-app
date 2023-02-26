
import 'package:CoWork/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show Uint8List, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';


class Chatapalooza extends StatefulWidget {
  const Chatapalooza(this.chatgpt_initial_response, this.page_name, this.page_access_token, this.page_id, {super.key});

  final String? page_name;
  final String? chatgpt_initial_response;
  final String? page_access_token;
  final String? page_id;

  @override
  State<Chatapalooza> createState() => _ChatapaloozaState();
}

class _ChatapaloozaState extends State<Chatapalooza> {

  String? page_name = "";
  String? chatgpt_initial_response;
  String? page_access_token = "";
  String? page_id = "";

  List<types.Message> _messages = [];
  final _user = const types.User(id: '82091008-a484-4a89-ae75-a22bf8d6f3ac'); // not confidential; simply utilized to distinguish between two users in the same session (dynamically generated)
  final _cowork = const types.User(id: '82091008-a484-4a89-ae75-a22bf8d6f3ab', imageUrl: 'https://i.pinimg.com/236x/45/a8/4e/45a84e1cab3bb3804c25c8bb08144467--fire-makeup-uv-makeup.jpg');

  String flow_step = '';
  String product_where = '';
  String product_what = '';
  String product_base64 = '';
  // vars + methods

  void _incrementCounter() {
    setState(() {

    });
  }

  Future _fetchPrefs() async{

    //

  }
  late Future _fetchPrefsVal = _fetchPrefs();

  Future start_flow() async{

    var toRemove = [];
    _messages.forEach( (e) {
      if(e.toString().contains(''))
        toRemove.add(e);
    });
    setState(() {
      _messages.removeWhere( (e) => toRemove.contains(e));
    });

    var textMessage = types.TextMessage(
      author: _cowork,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: chatgpt_initial_response!,
    );

    _addMessage(textMessage);

    textMessage = types.TextMessage(
      author: _cowork,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: "Welcome! Let's get started. Upload a product photo for " + page_name! + " to start a new flow.",
    );

    _addMessage(textMessage);

    var customPing = types.TextMessage(
      author: _cowork,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: "test",
      metadata: {
        'action_key': 'gen'
      }
    );
    _addMessage(customPing);


    flow_step = 'upload_product_photo';

  }

  void init_options(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 700),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Container(
            height: 240,
            child: SizedBox.expand(child: FlutterLogo()),
            margin: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(40)),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        Tween<Offset> tween;
        if (anim.status == AnimationStatus.reverse) {
          tween = Tween(begin: Offset(-1, 0), end: Offset.zero);
        } else {
          tween = Tween(begin: Offset(1, 0), end: Offset.zero);
        }

        return SlideTransition(
          position: tween.animate(anim),
          child: FadeTransition(
            opacity: anim,
            child: child,
          ),
        );
      },
    );
  }

  @override
  void initState() {
    page_name = widget.page_name;
    chatgpt_initial_response = widget.chatgpt_initial_response;
    page_access_token = widget.page_access_token;
    page_id = widget.page_id;
    initializeDateFormatting();
    super.initState();
    // init_options(context);
    start_flow();
    // _loadMessages();
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
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.fromLTRB(1, 0, 1, 4),
          child: Image.asset(
            'lib/assets/co-worker-logo.png',
            width: 154,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [

          Padding(
            padding: EdgeInsets.fromLTRB(4, 4, 4, 4),
            child: FloatingActionButton(
              onPressed: (){
                setState(() {
                  start_flow();
                  // _loadMessages();
                });
              },
              tooltip: 'Increment',
              child: const Icon(Icons.refresh),
            ),
          ),
          PopupMenuButton(
            // add icon, by default "3 dot" icon
            // icon: Icon(Icons.book)
              itemBuilder: (context){
                return [
                  PopupMenuItem<int>(
                    value: 0,
                    child: Text("My Account"),
                  ),

                  PopupMenuItem<int>(
                    value: 1,
                    child: Text("Settings"),
                  ),

                  PopupMenuItem<int>(
                    value: 2,
                    child: Text("Logout"),
                  ),
                ];
              },
              onSelected:(value){
                if(value == 0){
                  print("My account menu is selected.");
                }else if(value == 1){
                  print("Settings menu is selected.");
                }else if(value == 2){
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          MyApp(),
                    ),
                  );
                }
              }
          ),

        ],
      ),
      backgroundColor: buildMaterialColor(Color(0xFF323232)),
      body: Stack(
        children: [
          Image.asset(
            'lib/assets/co-worker-logo.png',
            width: 220,
          ),
          Chat(
            messages: _messages,
            theme: DefaultChatTheme(
              // inputBackgroundColor: buildMaterialColor(Color(0xFF323232)),
              backgroundColor:  buildMaterialColor(Color(0xFF323232)),
            ),
            onAttachmentPressed: _handleAttachmentPressed,
            onMessageTap: _handleMessageTap,
            onPreviewDataFetched: _handlePreviewDataFetched,
            onSendPressed: _handleSendPressed,
            showUserAvatars: true,
            showUserNames: true,
            user: _user,
          ),

        ],
      ),
      /*
      floatingActionButton: Padding(
        padding: EdgeInsets.fromLTRB(1, 1, 1, 75),
        child: FloatingActionButton(
          onPressed: (){
            setState(() {
              start_flow();
              // _loadMessages();
            });
          },
          tooltip: 'Increment',
          child: const Icon(Icons.refresh),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,   // This trailing comma makes auto-formatting nicer for build methods.

       */
    );
  }

  Future _cowork_cleanse() async{

    print('_cowork_cleanse() called');
    print(flow_step);
    var toRemove = [];
    _messages.forEach( (e) {
      if(e.toString().contains('loadingsupport.gif'))
        toRemove.add(e);
    });
    setState(() {
      _messages.removeWhere( (e) => toRemove.contains(e));
    });
  }

  Future gen_post() async{

    var gen_ig_post_title = '';
    var prompt = 'Generate a social media post title for a company called ' + page_name! + ' for a product with a goal ' + product_what + ' fun';
    var request = http.Request('GET', Uri.parse('https://us-central1-love-375210.cloudfunctions.net/chatgpt?prompt=' + prompt)); // public endpoint for hackathon (will be private in production)

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {

      var responseData = await response.stream.bytesToString();
      // Map valueMap = json.decode(responseData);
      print(responseData);
      gen_ig_post_title = responseData.trim();

      var textMessage = types.TextMessage(
        author: _cowork,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: "How about a title like this?\n\n" + gen_ig_post_title,
      );

      await _cowork_cleanse();
      await _addMessage(textMessage);
      _cowork_thinking();

    }
    else {
      print(response.reasonPhrase);
    }

    var gen_ig_post_description = '';
    prompt = 'Generate a social media post description for a company called ' + page_name! + ' for a product with a goal ' + product_what + ' fun';
    request = http.Request('GET', Uri.parse('https://us-central1-love-375210.cloudfunctions.net/chatgpt?prompt=' + prompt)); // public endpoint for hackathon (will be private in production)

    http.StreamedResponse response_description = await request.send();

    if (response.statusCode == 200) {

      var responseData_description = await response_description.stream.bytesToString();
      // Map valueMap = json.decode(responseData);
      print(responseData_description);
      gen_ig_post_description = responseData_description.trim();

      var textMessage = types.TextMessage(
        author: _cowork,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: "...and a description like this?\n\n" + gen_ig_post_description,
      );

      await _cowork_cleanse();
      await _addMessage(textMessage);
      _cowork_thinking();

    }
    else {
      print(response.reasonPhrase);
    }

    var sd_gen_prep = '';
    prompt = 'In 3 words, describe the background for a professional product photo for a company with the name ' + page_name! + ' for a social media post';
    request = http.Request('GET', Uri.parse('https://us-central1-love-375210.cloudfunctions.net/chatgpt?prompt=' + prompt)); // public endpoint for hackathon (will be private in production)

    http.StreamedResponse response_sd_gen_prep = await request.send();

    if (response.statusCode == 200) {

      var responseData_sd_gen_prep = await response_sd_gen_prep.stream.bytesToString();
      // Map valueMap = json.decode(responseData);
      print(responseData_sd_gen_prep);
      sd_gen_prep = responseData_sd_gen_prep.trim();

      var textMessage = types.TextMessage(
        author: _cowork,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: "...also, give me just a couple moments while I generate you a new product photo. I think these characteristics will look great:\n\n" + sd_gen_prep,
      );

      await _cowork_cleanse();
      await _addMessage(textMessage);
      _cowork_thinking();

      // sd init
      var headers = {
        'Content-Type': 'application/json',
        'Cookie': 'session-space-cookie=5b0182960d2e56435ac179a8d1e8b246'
      };
      var request = http.Request('POST', Uri.parse('https://tinsae-cowork.hf.space/run/test')); // public huggingface (hosted) models from our team for this hackathon (will be private in production)
      request.body = json.encode({
        "data": [
          "data:image/png;base64," + product_base64,
          product_what,
          sd_gen_prep
        ]
      });
      print('request info: ');
      print(request.body);
      request.headers.addAll(headers);

      http.StreamedResponse response_ds_photo = await request.send();

      if (response_ds_photo.statusCode == 200) {
        var responseData_sd_photo = await response_ds_photo.stream.bytesToString();
        // Map valueMap = json.decode(responseData);
        print(responseData_sd_photo);
        Map valueMap = json.decode(responseData_sd_photo);
        print(valueMap);

        final encodedStr = valueMap['data'][0].split(',')[1];
        Uint8List bytes = base64.decode(encodedStr);
        String dir = (await getApplicationDocumentsDirectory()).path;
        File file = File(
            "$dir/" + DateTime.now().millisecondsSinceEpoch.toString() + ".png");
        await file.writeAsBytes(bytes);
        var uri_ref = file.path;

        var upid = Uuid().v4();
        // _prefs.setString('loaderid', upid);
        var ping = types.ImageMessage(
          author: _cowork,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          height: 25,
          id: upid,
          name: 'loadingsupport',
          size: 2,
          uri: uri_ref,
          width: 25,
        );
        _addMessage(ping);

        _cowork_cleanse();

      }else{

        print(response_ds_photo.reasonPhrase);
        var textMessage = types.TextMessage(
          author: _cowork,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: const Uuid().v4(),
          text: "Ah, there was an issue: " + response_ds_photo.reasonPhrase.toString() + '. Trying again for you.',
        );

        await _cowork_cleanse();
        _addMessage(textMessage);
        await _cowork_thinking();
        await gen_post();

      }

    }else {
      print(response.reasonPhrase);
    }

    /*
    // title
      var token = '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';
      var openAI = OpenAI.instance.build(token: token,baseOption: HttpSetup(receiveTimeout: 20000),isLogger: true);

      var request = CompleteText(
          prompt:'What would be an inventive title for a social media post for a business who would like ' + product_what,
          model: 'text-davinci-003',
          maxTokens: 200
      );

      openAI.onCompleteStream(request:request).listen((response) async {
        // print(response?.trim());
        var response_string = response?.choices[0].text;
        print(response_string?.trim());
      });

      // description
      request = CompleteText(
          prompt:'What would be an inventive description (with hashtags) for a social media post for a business who would like ' + product_what,
          model: 'text-davinci-003',
          maxTokens: 200
      );

      openAI.onCompleteStream(request:request).listen((response) async {
        // print(response);
        var response_string = response?.choices[0].text;
        print(response_string?.trim());
      });

     */
  }

  Future _cowork_thinking() async{
    // final _prefs = await SharedPreferences.getInstance();
    var upid = Uuid().v4();
    // _prefs.setString('loaderid', upid);
    var ping = types.ImageMessage(
      author: _cowork,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      height: 25,
      id: upid,
      name: 'loadingsupport',
      size: 2,
      uri: 'https://firebasestorage.googleapis.com/v0/b/withfaithcowork.appspot.com/o/loadingsupport.gif?alt=media&token=8ce89545-c858-4a48-82bb-a058d451fb4c',
      width: 25,
    );
    _addMessage(ping);
  }

  Future _addMessage(types.Message message) async{

    setState(() {
      _messages.insert(0, message);
    });

    print(_messages);

    if(flow_step == 'upload_product_photo_where'){
      // product_where = message.text.toString().toLowerCase();
      var textMessage = types.TextMessage(
        author: _cowork,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: "Okay. What is the purpose of your post?",
      );

      // _addMessage(textMessage);
      flow_step = 'what_is_the_purpose_of_your_post';
      _addMessage(textMessage);

    }
    if(flow_step == 'generating_photo'){
      var textMessage = types.TextMessage(
        author: _cowork,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: "Thanks. Generating a new post for you now.",
      );

      flow_step = 'actually_generating_photo_now';
      _addMessage(textMessage);
      _cowork_thinking();

      // print('product_where: ' + product_where);
      print('product_what: ' + product_what);
      print('product_base64: ' + product_base64);

      await gen_post();

      // background
      // stable diffusion

    }

  }

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          height: 144,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleImageSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Photo'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleFileSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('File'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      final message = types.FileMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        mimeType: lookupMimeType(result.files.single.path!),
        name: result.files.single.name,
        size: result.files.single.size,
        uri: result.files.single.path!,
      );

      _addMessage(message);
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);
      var base64_encoding = base64Encode(bytes);
      // print(base64_version);

      print(result.path);

      var ping = types.ImageMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: const Uuid().v4(),
        name: result.name,
        size: bytes.length,
        uri: result.path,
        width: image.width.toDouble(),
      );

      _addMessage(ping);

      // final _prefs = await SharedPreferences.getInstance();
      if (flow_step == 'upload_product_photo') {
        _cowork_thinking();
        // base64_encoding
        print(base64_encoding);


        var headers = {
          'Content-Type': 'application/json'
        };
        var request = http.Request('POST', Uri.parse(
            'https://fffiloni-clip-interrogator-2.hf.space/run/clipi2')); // public model via huggingface for hackathon (https://huggingface.co/spaces/fffiloni/CLIP-Interrogator-2/blob/main/app.py)
        request.body = json.encode({
          "data": [
            "data:image/png;base64," + base64_encoding,
            "fast",
            "3"
          ]
        });
        request.headers.addAll(headers);
        product_base64 = base64_encoding;

        http.StreamedResponse response = await request.send();

        if (response.statusCode == 200) {
          final responseData = await response.stream.bytesToString();
          Map valueMap = json.decode(responseData);
          var clip_interragator_finding = valueMap['data'][0].split(',')[0];
          print(clip_interragator_finding);

          await _cowork_cleanse();

          var textMessage = types.TextMessage(
            author: _cowork,
            createdAt: DateTime.now().millisecondsSinceEpoch,
            id: const Uuid().v4(),
            text: "Great. I'm seeing " + clip_interragator_finding +
                ". What is the purpose of your post?",
          );

          flow_step = 'what_is_the_purpose_of_your_post';
          _addMessage(textMessage);

          // final _prefs = await SharedPreferences.getInstance();
          product_base64 = base64_encoding;
          product_what = clip_interragator_finding;

        } else {
          print(response.reasonPhrase);


          var textMessage = types.TextMessage(
            author: _cowork,
            createdAt: DateTime.now().millisecondsSinceEpoch,
            id: const Uuid().v4(),
            text: "Thanks. Now using as few words as possible, describe your product.",
          );

          await Future.delayed(Duration(seconds: 1));
          await _cowork_cleanse();

          flow_step = 'upload_product_photo_asking_user_for_brief_description';
          _addMessage(textMessage);

          // final _prefs = await SharedPreferences.getInstance();

          }

          // }
        }
      }
    }

  void _handleMessageTap(BuildContext _, types.Message message) async {
      if (message is types.FileMessage) {
        var localPath = message.uri;

        if (message.uri.startsWith('http')) {
          try {
            final index =
            _messages.indexWhere((element) => element.id == message.id);
            final updatedMessage =
            (_messages[index] as types.FileMessage).copyWith(
              isLoading: true,
            );

            setState(() {
              _messages[index] = updatedMessage;
            });

            final client = http.Client();
            final request = await client.get(Uri.parse(message.uri));
            final bytes = request.bodyBytes;
            final documentsDir = (await getApplicationDocumentsDirectory())
                .path;
            localPath = '$documentsDir/${message.name}';

            if (!File(localPath).existsSync()) {
              final file = File(localPath);
              await file.writeAsBytes(bytes);
            }
          } finally {
            final index =
            _messages.indexWhere((element) => element.id == message.id);
            final updatedMessage =
            (_messages[index] as types.FileMessage).copyWith(
              isLoading: null,
            );

            setState(() {
              _messages[index] = updatedMessage;
            });
          }
        }

        await OpenFilex.open(localPath);
      }
      if(message is types.TextMessage){
        print(message.metadata);
      }
    }

  void _handlePreviewDataFetched(types.TextMessage message,
        types.PreviewData previewData,) {
      final index = _messages.indexWhere((element) => element.id == message.id);
      final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
        previewData: previewData,
      );

      setState(() {
        _messages[index] = updatedMessage;
      });
    }

  void _handleSendPressed(types.PartialText message) {
      var textMessage = types.TextMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: message.text,
      );
      print('here1');
      print(message.text);
      print('flow_step: ');
      print(flow_step);
      if(flow_step == 'upload_product_photo_asking_user_for_brief_description'){
        flow_step = 'upload_product_photo_where';
      }
      if(flow_step == 'what_is_the_purpose_of_your_post'){
        flow_step = 'generating_photo';
      }

      _addMessage(textMessage);

    }

  void _loadMessages() async {
      final response = await rootBundle.loadString('assets/messages.json');
      final messages = (jsonDecode(response) as List)
          .map((e) => types.Message.fromJson(e as Map<String, dynamic>))
          .toList();

      setState(() {
        _messages = messages;
      });
    }
}