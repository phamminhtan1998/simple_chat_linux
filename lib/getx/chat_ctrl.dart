import 'dart:convert';

import 'package:get/get.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:translate/model/text_message_dto.dart';

class ChatCtrl extends GetxController{
  var chatFrame = List<Message>().obs;
  final socketUrl = 'http://localhost:9000/ws-message';
  var name ="".obs;
  var to = "".obs;

  @override
  void onInit() {
    Message message =new Message(
      from: "MinhTan",
        message: "Hello there",
        to: "dieulinh"
    );
    Message messageRes =new Message(
        from: "dieulinh",
        message: "Hello there fafafaf",
        to: "MinhTan"
    );
   chatFrame.value.add(message);
   chatFrame.value.add(messageRes);
  //

  }



}