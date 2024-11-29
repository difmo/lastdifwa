import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class BottleController extends GetxController {
  var bottleItems = <Map<String, dynamic>>[].obs;

  void fetchBottleItems() {
    FirebaseFirestore.instance
        .collection('bottleItems')
        .snapshots()
        .listen((snapshot) {
      bottleItems.clear();
      for (var doc in snapshot.docs) {
        bottleItems.add({
          'size': doc['size'],
          'price': doc['price'],
          'timestamp': doc['timestamp'],
          'userId': doc['userId'],
          'vacantPrice': doc['vacantPrice'],
        });
      }
    });
  }

  @override
  void onInit() {
    super.onInit();
    fetchBottleItems(); // Fetch data when the controller is initialized
  }
}
