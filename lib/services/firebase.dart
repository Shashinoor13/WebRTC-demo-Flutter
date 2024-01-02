import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseApi {
  DocumentReference<Object?> getRoomDocumentReference() {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference roomRef = db.collection('calling_rooms').doc();

    return roomRef;
  }

  getRoomByDocumentId({required String roomId}) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference roomRef = db.collection('calling_rooms').doc(roomId);
    DocumentSnapshot<Object?> roomSnapshot = await roomRef.get();

    return roomSnapshot;
  }
}
