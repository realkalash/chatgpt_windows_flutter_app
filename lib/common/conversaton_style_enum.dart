class ConversationLengthStyleEnum {
  String name;
  String? prompt;
  int? maxTokenLenght;

  ConversationLengthStyleEnum(
    this.name,
    this.prompt, {
    this.maxTokenLenght,
  });

  static ConversationLengthStyleEnum short = ConversationLengthStyleEnum(
      'Short', '(Keep answer short)',
      maxTokenLenght: 500);
  static ConversationLengthStyleEnum normal =
      ConversationLengthStyleEnum('Normal', null, maxTokenLenght: 1024);
  static ConversationLengthStyleEnum detailed = ConversationLengthStyleEnum(
      'Detailed', '(Be precise and detailed)',
      maxTokenLenght: 4096);

  static List<ConversationLengthStyleEnum> values = [
    short,
    normal,
    detailed,
  ];

  static ConversationLengthStyleEnum? fromName(String name) {
    for (var item in values) {
      if (item.name == name) {
        return item;
      }
    }
    return null;
  }

  @override
  String toString() {
    return name;
  }

  ConversationLengthStyleEnum copyWith(
      {String? name, String? prompt, int? maxTokenLenght}) {
    return ConversationLengthStyleEnum(
      name ?? this.name,
      prompt ?? this.prompt,
      maxTokenLenght: maxTokenLenght ?? this.maxTokenLenght,
    );
  }
}

class ConversationStyleEnum {
  final String name;
  final String? prompt;

  ConversationStyleEnum(this.name, this.prompt);

  static ConversationStyleEnum normal = ConversationStyleEnum('Normal', null);
  static ConversationStyleEnum business =
      ConversationStyleEnum('Business', '(Use business language)');
  static ConversationStyleEnum casual =
      ConversationStyleEnum('Casual', '(Use casual language)');
  static ConversationStyleEnum friendly =
      ConversationStyleEnum('Friendly', '(Use friendly language)');
  static ConversationStyleEnum professional =
      ConversationStyleEnum('Professional', '(Use professional language)');
  static ConversationStyleEnum seductive =
      ConversationStyleEnum('Seductive', '(Be seductive in your answer)');

  static List<ConversationStyleEnum> values = [
    normal,
    business,
    casual,
    friendly,
    professional,
    seductive,
  ];

  static ConversationStyleEnum? fromName(String name) {
    for (var item in values) {
      if (item.name == name) {
        return item;
      }
    }
    return null;
  }

  @override
  String toString() {
    return name;
  }
}
