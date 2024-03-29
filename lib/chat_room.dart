import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';

class ChatRoom {
  String chatRoomName;
  ChatModel model;
  double temp;
  int topk;
  int promptBatchSize;
  int repeatPenaltyTokens;
  double topP;
  int maxLength;
  double repeatPenalty;

  /// Api key for the chat model
  String token;
  String? orgID;

  /// <DateTime, <key, value>>
  Map<String, Map<String, String>> messages;
  String? commandPrefix;

  ChatRoom({
    required this.chatRoomName,
    required this.messages,
    required this.model,
    required this.temp,
    required this.topk,
    required this.promptBatchSize,
    required this.repeatPenaltyTokens,
    required this.topP,
    required this.maxLength,
    required this.repeatPenalty,
    required this.token,
    this.orgID,
    this.commandPrefix,
  });

  @override
  int get hashCode => chatRoomName.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatRoom &&
          runtimeType == other.runtimeType &&
          chatRoomName == other.chatRoomName;

  ChatRoom.fromMap(Map<String, dynamic> map)
      : model = allModels.firstWhere(
          (element) => element.toString() == map['model'],
          orElse: () => allModels.first,
        ),
        chatRoomName = map['chatRoomName'],
        temp = map['temp'],
        topk = map['topk'],
        promptBatchSize = map['promptBatchSize'],
        repeatPenaltyTokens = map['repeatPenaltyTokens'],
        topP = map['topP'],
        maxLength = map['maxLength'],
        repeatPenalty = map['repeatPenalty'],
        token = map['token'],
        orgID = map['orgID'],
        commandPrefix = map['commandPrefix'],
        messages = (map['messages'] as Map).map(
          (key, value) {
            return MapEntry(key, Map<String, String>.from(value));
          },
        );

  Map<String, dynamic> toJson() => {
        'model': model.model.toString(),
        'chatRoomName': chatRoomName,
        'messages': messages,
        'temp': temp,
        'topk': topk,
        'promptBatchSize': promptBatchSize,
        'repeatPenaltyTokens': repeatPenaltyTokens,
        'topP': topP,
        'maxLength': maxLength,
        'repeatPenalty': repeatPenalty,
        'token': token,
        'orgID': orgID,
        'commandPrefix': commandPrefix,
      };

  ChatRoom copyWith({
    String? chatRoomName,
    Map<String, Map<String, String>>? messages,
    ChatModel? model,
    double? temp,
    int? topk,
    int? promptBatchSize,
    int? repeatPenaltyTokens,
    double? topP,
    int? maxLength,
    double? repeatPenalty,
    String? token,
    String? orgID,
    String? commandPrefix,
  }) {
    return ChatRoom(
      chatRoomName: chatRoomName ?? this.chatRoomName,
      messages: messages ?? this.messages,
      model: model ?? this.model,
      temp: temp ?? this.temp,
      topk: topk ?? this.topk,
      promptBatchSize: promptBatchSize ?? this.promptBatchSize,
      repeatPenaltyTokens: repeatPenaltyTokens ?? this.repeatPenaltyTokens,
      topP: topP ?? this.topP,
      maxLength: maxLength ?? this.maxLength,
      repeatPenalty: repeatPenalty ?? this.repeatPenalty,
      token: token ?? this.token,
      orgID: orgID ?? this.orgID,
      commandPrefix: commandPrefix ?? this.commandPrefix,
    );
  }
}

final allModels = [
  GPT4TurboModel(),
  Gpt4ChatModel(),
  GptTurboChatModel(),
  GptTurbo0301ChatModel(),
  Gpt4VisionPreviewChatModel(),
];

class GPT4TurboModel extends ChatModelFromValue {
  GPT4TurboModel() : super(model: 'gpt-4-0125-preview');
}
