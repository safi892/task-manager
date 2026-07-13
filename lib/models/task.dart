class Task {
  String? uid;
  String title;
  String description;
  bool isCompleted;
  DateTime? dueDate;
  String? priority;
  bool isFavourite;

  Task({
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.dueDate,
    this.priority,
    this.isFavourite = false,
  });
  Task copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    String? priority,
    bool? isCompleted,
     bool? isFavourite, 
  }) {
    return Task(
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      isFavourite: isFavourite ?? this.isFavourite,
    );
  }
  Map<String, dynamic> toMap() => {
  'title': title,
  'description': description,
  'isCompleted': isCompleted,
  'dueDate': dueDate?.toIso8601String(),
  'priority': priority,
  'isFavourite': isFavourite,
};

factory Task.fromFirestore(String uid, Map<String, dynamic> map) => Task(
  title: map['title'] ?? '',
  description: map['description'] ?? '',
  isCompleted: map['isCompleted'] ?? false,
  dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
  priority: map['priority'],
  isFavourite: map['isFavourite'] ?? false,
)..uid = uid;
}
