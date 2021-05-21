import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:translate/model/text_message_dto.dart';
import 'package:translate/screen/chat_page.dart';
import 'package:window_size/window_size.dart';

final socketUrl = 'http://localhost:9000/ws-message';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final title = 'Websocket Demo';
    return MaterialApp(
      title: title,
      home: ChatPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StompClient stompClient;

  String message = '';

  void onConnect(StompFrame frame) {
    stompClient.subscribe(
        destination: '/topic/message',
        callback: (StompFrame frame) {
          if (frame.body != null) {
            print('Connect thanh cong');
            Map<String, dynamic> result = json.decode(frame.body);
            print(result['message']);
            setState(() => message = result['message']);
          }
        });
  }

  @override
  void initState() {
    super.initState();

    if (stompClient == null) {
      stompClient = StompClient(
          config: StompConfig.SockJS(
            url: socketUrl,
            onConnect: onConnect,
            onWebSocketError: (dynamic error) => print(error.toString()),
          ));

      stompClient.activate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Your message from server:',
            ),
            Text(
              '$message',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.message),
        onPressed: (){
          print('Sending message with json encode  ');
          Message mess = new Message(from: "Minh Tan ",message: "Anh yeu em   ",to: "dieu linh");
          stompClient.send(destination: "/app/message",body: json.encode(mess));
        },
      ),
    );

  }

  @override
  void dispose() {
    if (stompClient != null) {
      stompClient.deactivate();
    }

    super.dispose();
  }
}