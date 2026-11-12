class NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime receivedAt;
  final bool isRead;
  final String? screenToOpen;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.receivedAt,
    this.isRead = false,
    this.screenToOpen,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'receivedAt': receivedAt.millisecondsSinceEpoch,
      'isRead': isRead,
      'screenToOpen': screenToOpen,
    };
  }

  factory NotificationItem.fromMap(Map<String, dynamic> map, String docId) {
    return NotificationItem(
      id: docId.isNotEmpty ? docId : (map['id'] ?? ''),
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      receivedAt: map['receivedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['receivedAt'])
          : DateTime.now(),
      isRead: map['isRead'] ?? false,
      screenToOpen: map['screenToOpen'],
    );
  }
}

