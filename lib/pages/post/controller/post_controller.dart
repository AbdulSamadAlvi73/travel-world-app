import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:roam_the_world_app/models/postmodel.dart';
import 'package:roam_the_world_app/pages/main/main_screen.dart';

class PostController extends GetxController {
  final uId = FirebaseAuth.instance.currentUser!.uid;

  /* ───────────────── image upload ───────────────── */
  Future<List<String>> uploadImages(List<File> images) async {
    final List<String> urls = [];
    for (var img in images) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('posts/${DateTime.now().millisecondsSinceEpoch}.jpg');
      try {
        await ref.putFile(img);
        urls.add(await ref.getDownloadURL());
      } catch (_) {
        Get.snackbar('Error', 'Failed to upload an image');
      }
    }
    return urls;
  }

  /* ───────────────── add post ───────────────── */
  Future<void> addPostToFirebase(
      String uId,
      String province,
      String city,
      String name,
      String destination,
      String airline,
      String startDate,
      String endDate,
      String experience,
      List<String> imageUrls,
      List<String> tags, // ← now a List
      bool allowContact,
      String deviceToken,
      String status,
      String country,
      ) async {
    try {
      final post = PostModel(
        uId: uId,
        province: province,
        name: name,
        city: city,
        destination: destination,
        airline: airline,
        startDate: startDate,
        endDate: endDate,
        experience: experience,
        imageUrls: imageUrls,
        tags: tags,
        allowcontact: allowContact,
        devicetoken: deviceToken,
        status: status,
        country: country,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uId)
          .collection('posts')
          .add(post.toMap());

      await FirebaseFirestore.instance.collection('posts').add(post.toMap());

      Get.offAll(MainScreen());
      Get.snackbar("Success", "Post published",
          backgroundColor: Colors.blue, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  /* ───────────────── update post (tags also List) ───────────────── */
  Future<void> updatePostInFirebase(
      String postId,
      String uId,
      String province,
      String city,
      String name,
      String destination,
      String airline,
      String startDate,
      String endDate,
      String experience,
      List<File> newImages,
        List<String> tags, // ← List
      bool allowContact,
      ) async {
    try {
      EasyLoading.show(status: "Updating post…");

      // delete old images
      final postRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uId)
          .collection('posts')
          .doc(postId);

      final snap = await postRef.get();
      final List<dynamic> oldUrls = snap.data()?['imageUrls'] ?? [];
      for (var url in oldUrls) {
        try {
          await FirebaseStorage.instance.refFromURL(url).delete();
        } catch (_) {}
      }

      // upload new
      final newUrls = await uploadImages(newImages);

      // new post model
      final post = PostModel(
        uId: uId,
        province: province,
        name: name,
        city: city,
        destination: destination,
        airline: airline,
        startDate: startDate,
        endDate: endDate,
        experience: experience,
        imageUrls: newUrls,
        tags: tags,
        allowcontact: allowContact,
      );

      await postRef.update(post.toMap());
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('uId', isEqualTo: uId)
          .get();
      print(snapshot.docs);

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          String postDocId = doc.id;
          print(("document is ijd this $postDocId"));

          // 3. Update each found document (in case there are multiple)
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(postDocId)
              .update(post.toMap());
        }
      }

      EasyLoading.dismiss();
      print("dalla");
      Get.offAll(MainScreen());
      Get.snackbar(
          "Success",
          "Post updated Successfully",
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM
      );
    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar("Error", e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
