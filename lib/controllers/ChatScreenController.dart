import 'package:camera/camera.dart';
import 'package:chat_demo/models/ChatRoomModel.dart';
import 'package:chat_demo/models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../Firebase/FirebaseHelper.dart';

class ChatScreenController extends GetxController {
  RxBool isSend = false.obs;
  RxMap<String, List<ChatModel>> messageList = <String, List<ChatModel>>{}.obs;
  Rx<List<ChatModel>>? list = Rx([]);
  RxList<UserModel> friendsList = <UserModel>[].obs;
  RxList<String> friendsIdList = <String>[].obs;
  RxString picture = ''.obs;
  CameraController? cameraController;
  RxBool loadCamera = false.obs;
  List<CameraDescription>? cameras = [];
  CameraDescription? activeCamera;
  Rx<Stream<QuerySnapshot<Map<String, dynamic>>>?> stream = Rx(null);

  @override
  void onInit() {
    initializeCamerasOnStart();
    super.onInit();
  }

  void getMessages(String chatroomId, var lMsgTime) async {
    if (lMsgTime == null) list?.value = messageList[chatroomId] ?? [];
    var data = lMsgTime == null
        ? await FBHelper().getMessages(chatroomId)
        : await FBHelper().getMoreMessages(chatroomId, lMsgTime);

    var msg = data.docs.map((e) => ChatModel.fromJson(e.data())).toList();

    if (lMsgTime == null) {
      list?.value = msg;
    } else {
      for (var newMsg in msg) {
        if (!list!.value.any((oldMsg) => oldMsg.time == newMsg.time)) {
          list?.value.add(newMsg);
        }
      }
      list?.refresh();
    }

    list?.value.sort((a, b) => b.time!.compareTo(a.time!));
    messageList[chatroomId] = list?.value ?? [];
  }

  Future<void> getfriendList() async {
    var frd = await FirebaseFirestore.instance
        .collection(FBHelper.users)
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection(FBHelper.friends)
        .get();

    var frdId = frd.docs.map((e) => e.id).toList();

    friendsIdList.value = frdId;
    if (frdId.isNotEmpty) {
      var data = await FirebaseFirestore.instance
          .collection(FBHelper.users)
          .where('uid', whereIn: frdId)
          .get();

      friendsList.value = data.docs.map((e) {
        return UserModel.fromJson(e.data());
      }).toList();
      friendsIdList.refresh();
      friendsList.refresh();
    }
  }

  Future<void> sendPicture(ImageSource source) async {
    var pickedPicture = await ImagePicker().pickImage(source: source);
    if (pickedPicture != null) {
      picture.value = pickedPicture.path;
    }
  }

  Future<void> captureImage() async {
    if (cameraController != null && cameraController!.value.isInitialized) {
      try {
        final XFile capturedImage = await cameraController!.takePicture();
        picture.value = capturedImage.path;
      } catch (e) {
        print('Error occur while capture image =>  $e');
      }
    }
  }

  Future<void> initializeCamerasOnStart() async {
    cameras = await availableCameras();

    // Use the rear camera as default
    CameraDescription initialCamera = cameras!.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras![0],
    );

    await initializeCamera(initialCamera);
  }

  Future<void> initializeCamera(CameraDescription cameraDescription) async {
    cameraController =
        CameraController(cameraDescription, ResolutionPreset.max);

    // Initialize the camera controller
    if (cameraController != null) {
      await cameraController?.initialize();
      activeCamera = cameraDescription;
      loadCamera.refresh();
    }
  }

  Future<void> toggleCamera() async {
    if (cameras == null || cameras!.isEmpty) return;
    CameraDescription? newCamera;
    if (activeCamera?.lensDirection == CameraLensDirection.front) {
      newCamera = cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras![0],
      );
    } else {
      newCamera = cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras![0],
      );
    }

    if (newCamera != activeCamera) {
      await initializeCamera(newCamera);
    }
  }

  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }
}
