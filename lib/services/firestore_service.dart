import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_manager/models/task.dart';

class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference get _tasksCollection =>
      _firestore.collection('users').doc(_userId).collection('tasks');

  Stream<List<Task>> streamTasks() {
    return _tasksCollection
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Task.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<void> addTask(Task task) async {
    final docRef = await _tasksCollection.add(task.toMap());
    task.uid = docRef.id;
  }

  Future<void> updateTask(Task task) async {
    if (task.uid == null) return;
    await _tasksCollection.doc(task.uid!).update(task.toMap());
  }

  Future<void> deleteTask(String taskId) async {
    await _tasksCollection.doc(taskId).delete();
  }

  Future<void> toggleTaskStatus(String taskId, bool isCompleted) async {
    await _tasksCollection.doc(taskId).update({'isCompleted': isCompleted});
  }

  Future<void> toggleTaskFavourite(String taskId, bool isFavourite) async {
    await _tasksCollection.doc(taskId).update({'isFavourite': isFavourite});
  }
}
