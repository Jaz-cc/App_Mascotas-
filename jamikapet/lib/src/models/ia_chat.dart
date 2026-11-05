class Iachat {
  final String? id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  Iachat({
    this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  factory Iachat.fromJson(Map<String, dynamic> json) {
    return Iachat(
      id: json['id'],
      text: json['prompt'] ?? json['reply'] ?? json['text'] ?? '',
      isUser: json['isUser'] ?? false,
      timestamp: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}