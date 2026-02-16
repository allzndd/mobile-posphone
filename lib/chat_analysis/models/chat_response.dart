class ChatResponse {
  final bool ok;
  final String? answer;
  final String? intent;
  final dynamic data;
  final String? error;

  ChatResponse({
    required this.ok,
    this.answer,
    this.intent,
    this.data,
    this.error,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      ok: json['ok'] ?? false,
      answer: json['answer'],
      intent: json['intent'],
      data: json['data'],
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ok': ok,
      'answer': answer,
      'intent': intent,
      'data': data,
      'error': error,
    };
  }
}
