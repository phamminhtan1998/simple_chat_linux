class Message {
  String message;
  String from;
  String to;

  Message({this.message, this.from, this.to});

  Message.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    from = json['from'];
    to = json['to'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['from'] = this.from;
    data['to'] = this.to;
    return data;
  }
}