import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:translate/getx/chat_ctrl.dart';
import 'package:translate/model/text_message_dto.dart';

class ChatPage extends StatelessWidget {
  final socketUrl = 'http://localhost:9000/ws-message';
  String message;
  TextEditingController txtNameCtrl = new TextEditingController();
  TextEditingController txtMessageCtrl = new TextEditingController();
  StompClient stompClient;
  ChatCtrl chatCtrl = Get.put(ChatCtrl());
  @override
  Widget build(BuildContext context) {
    if (stompClient == null) {
      stompClient = StompClient(
          config: StompConfig.SockJS(
        url: socketUrl,
        onConnect: (StompFrame frame) => stompClient.subscribe(
            destination: '/topic/message',
            callback: (StompFrame frame) {
              if (frame.body != null) {
                Message message = Message.fromJson(json.decode(frame.body));
                // ignore: unrelated_type_equality_checks
                if(message.from!=this.chatCtrl.name){
                  print('message from client ');
                  this.chatCtrl.chatFrame.add(message);
                }
              }
            }),
        onWebSocketError: (dynamic error) => print(error.toString()),
      ));
      stompClient.activate();
    }


    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          flexibleSpace: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: SafeArea(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage("https://picsum.photos/200"),
                  maxRadius: 50,
                ),
                title: Obx(()=> Text(this.chatCtrl.to.value ?? "Unknow person")),
                subtitle: Text("Online"),
                trailing: Icon(Icons.settings),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            TextField(
              controller: txtNameCtrl,
              decoration: InputDecoration(hintText: "Enter your name "),
            ),
            TextButton(
                onPressed: () {
                  this.chatCtrl.name.value = txtNameCtrl.text;
                },
                child: Text("Tham gia")),
            Divider(
              height: 10,
              color: Colors.green,
            ),
            Expanded(
                child: Obx(
                  ()=> Stack(
              children: [
                  ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    physics: BouncingScrollPhysics(),
                    itemCount: this.chatCtrl.chatFrame.value.length,
                    itemBuilder: (context, index) {
                      Message message =
                          this.chatCtrl.chatFrame.value.elementAt(index);
                      return Container(
                        margin: EdgeInsets.only(bottom: 10),
                        child: Align(
                          alignment: this.chatCtrl.name == message.from
                              ? Alignment.topLeft
                              : Alignment.topRight,
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: this.chatCtrl.name == message.from
                                    ? Colors.blue
                                    : Colors.pink),
                            margin: EdgeInsets.symmetric(horizontal: 40),
                            padding: EdgeInsets.all(16),
                            child: Text(
                              message.message,
                              style: TextStyle(fontSize: 15, color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    },
                  )
              ],
            ),
                )),
            Divider(
              height: 10,
              color: Colors.green,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    flex:4,
                    child: TextField(
                      controller: txtMessageCtrl,
                      textInputAction: TextInputAction.go,
                      decoration: InputDecoration(
                        hintText: "Enter your message !",
                      ),
                      onSubmitted: (message){
                        sendMessage(message);
                      },
                    ),
                  ),
                  Expanded(child: TextButton(
                    onPressed: (){

                      sendMessage(this.txtMessageCtrl.text);
                    },
                    child: Text(
                      "Send"
                    ),
                  ))
                ],
              ),
            ),
          ],
        ));
  }
  Function sendMessage(String message ){
    Message mess = new Message(
      from: this.chatCtrl.name.value,
      to: this.chatCtrl.to.value,
      message: message,
    );
    this.chatCtrl.chatFrame.add(mess);
    print('Sending message !');
    txtMessageCtrl.text="";
    stompClient.send(destination: "/app/message",body:json.encode(mess));
  }
}
