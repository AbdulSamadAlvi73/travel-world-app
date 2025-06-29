import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:roam_the_world_app/services/Notifiction-Service.dart';
import 'package:roam_the_world_app/utils/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:roam_the_world_app/widgets/custom_button.dart';
import 'package:roam_the_world_app/widgets/custom_text_field.dart';

import 'controller/post_controller.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  /* ───────────────── controllers / state ───────────────── */
  final postController = Get.put(PostController());
  final uId = FirebaseAuth.instance.currentUser?.uid.toString();
  Map<String, dynamic>? userdata;

  // main input controllers
  final provinceC = TextEditingController();
  final nameC = TextEditingController();
  final cityC = TextEditingController();
  final destinationC = TextEditingController();
  final airlineC = TextEditingController();
  final experienceC = TextEditingController();
  final startDateC = TextEditingController();
  final endDateC = TextEditingController();

  // tag-specific
  final tagInputC = TextEditingController();
  final List<String> tags = [];

  /* ───────────────── other state ───────────────── */
  List<File> selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool allowContact = false;

  late Color statusColor;
  late String status;
  late String locationName;

  /* ───────────────── lifecycle ───────────────── */
  @override
  void initState() {
    super.initState();
    _fetchUser();

    final args = Get.arguments;
    statusColor = Color(args['color']);
    status = args['status'];
    locationName = args['locationName'];
  }

  Future<void> _fetchUser() async {
    final snap =
    await FirebaseFirestore.instance.collection('users').doc(uId).get();
    if (snap.exists) setState(() => userdata = snap.data());
  }

  /* ───────────────── helpers ───────────────── */
  Future<void> _pickImages() async {
    final List<XFile>? imgs = await _picker.pickMultiImage();
    if (imgs != null && imgs.isNotEmpty) {
      setState(() => selectedImages.addAll(imgs.map((x) => File(x.path))));
    }
  }

  Future<void> _pickDate(TextEditingController target) async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      target.text = DateFormat('dd-MM-yyyy').format(picked);
    }
  }

  /* ----- tag helpers ----- */
  void _addTag() {
    final t = tagInputC.text.trim();
    if (t.isNotEmpty && !tags.contains(t)) setState(() => tags.add(t));
    tagInputC.clear();
  }

  void _removeTag(String t) => setState(() => tags.remove(t));

  /* ───────────────── build ───────────────── */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kWhiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.kWhiteColor,
        elevation: 0,
        title: Text(locationName,
            style:
            GoogleFonts.poppins(fontWeight: FontWeight.w400, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 30.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            SizedBox(height: 24.h),
            _imagePicker(),
            SizedBox(height: 24.h),
            _textField("Your Name", nameC),
            _textField("Province", provinceC),
            _textField("City", cityC),
            _textField("Destination", destinationC),
            _textField("Airline", airlineC),
            _dateRow(),
            _tagSection(),
            _textField("Share your experience", experienceC, description: true),
            _contactCheckbox(),
            SizedBox(height: 24.h),
            Center(
              child: CustomButton(
                onPressed: _publish,
                text: "Publish",
                width: 200.w,
                height: 42.h,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* ───────────────── small UI widgets ───────────────── */

  Widget _header() => Column(
    children: [
      Container(
        padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 15.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFDF4FF),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.kBorderColor),
        ),
        child: Text("Add Post",
            style: GoogleFonts.poppins(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor)),
      ),
      SizedBox(height: 12.h),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text("Added to: ",
            style: GoogleFonts.poppins(
                fontSize: 12.sp, color: AppColors.kTextColor)),
        SizedBox(width: 12.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
          decoration: BoxDecoration(
              color: const Color(0xFFFDF4FF),
              borderRadius: BorderRadius.circular(100)),
          child: Row(children: [
            Container(
                width: 10.w,
                height: 10.h,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: statusColor)),
            SizedBox(width: 8.w),
            Text(status,
                style: GoogleFonts.poppins(
                    fontSize: 12.sp, color: AppColors.kTextColor)),
          ]),
        )
      ])
    ],
  );

  Widget _imagePicker() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label("Add Images"),
      SizedBox(height: 12.h),
      GestureDetector(
        onTap: _pickImages,
        child: Container(
          height: 170.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColors.primaryColor),
          ),
          child: selectedImages.isEmpty
              ? Center(
            child: Text("+ Add Feature Images",
                style: GoogleFonts.poppins(
                    fontSize: 16.sp, color: AppColors.kTextColor)),
          )
              : ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Image.file(selectedImages[0],
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover),
          ),
        ),
      ),
      SizedBox(height: 12.h),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              width: 75.w,
              height: 75.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: AppColors.primaryColor,
                ),
              ),
              child: selectedImages.length <= 1
                  ? Center(
                child: Text(
                  "+ ",
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    color: AppColors.kTextColor,
                  ),
                ),
              )
                  :
              Stack(
                children: [
                  // Display the first selected image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Image.file(
                      selectedImages[1],
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Counter showing number of selected images

                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              width: 75.w,
              height: 75.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: AppColors.primaryColor,
                ),
              ),
              child:
              selectedImages.length <= 2
                  ? Center(
                child: Text(
                  "+ ",
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    color: AppColors.kTextColor,
                  ),
                ),
              )
                  :
              Stack(
                children: [
                  // Display the first selected image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Image.file(
                      selectedImages[2],
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Counter showing number of selected images

                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              width: 75.w,
              height: 75.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: AppColors.primaryColor,
                ),
              ),
              child:
              selectedImages.length <= 3
                  ? Center(
                child: Text(
                  "+",
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    color: AppColors.kTextColor,
                  ),
                ),
              )
                  :
              Stack(
                children: [
                  // Display the first selected image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Image.file(
                      selectedImages[3],
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Counter showing number of selected images

                ],
              ),                    ),
          ),
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              width: 100.w,
              height: 75.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: AppColors.primaryColor,
                ),
              ),
              child:
              selectedImages.length <= 4
                  ? Center(
                child: Text(
                  "+ ",
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    color: AppColors.kTextColor,
                  ),
                ),
              )
                  :
              Stack(
                children: [
                  // Display the first selected image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Image.file(
                      selectedImages[4],
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Counter showing number of selected images

                ],
              ),
            ),
          )
        ],
      ),
    ],
  );

  Widget _dateRow() => Row(children: [
    Expanded(
      child: CustomTextField(
        controller: startDateC,
        readOnly: true,
        hintText: "Start Date",
        suffixIcon: Icons.calendar_today,
        suffixPressed: () => _pickDate(startDateC),
      ),
    ),
    SizedBox(width: 24.w),
    Expanded(
      child: CustomTextField(
        controller: endDateC,
        readOnly: true,
        hintText: "End Date",
        suffixIcon: Icons.calendar_today,
        suffixPressed: () => _pickDate(endDateC),
      ),
    ),
  ]);

  Widget _tagSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label("Add Tags"),
      SizedBox(height: 12.h),
      Row(children: [
        Expanded(
          child: TextField(
            controller: tagInputC,
            decoration:
            const InputDecoration(hintText: "Type a tag, press +"),
            onSubmitted: (_) => _addTag(),
          ),
        ),
        IconButton(icon: const Icon(Icons.add), onPressed: _addTag)
      ]),
      Wrap(
        spacing: 8,
        children: tags
            .map((t) => Chip(
          label: Text(t),
          onDeleted: () => _removeTag(t),
        ))
            .toList(),
      ),
      SizedBox(height: 24.h),
    ],
  );

  Widget _contactCheckbox() => Row(children: [
    SizedBox(
        width: 20.w,
        height: 20.h,
        child: Checkbox(
          value: allowContact,
          onChanged: (v) => setState(() => allowContact = v ?? false),
        )),
    SizedBox(width: 8.w),
    Expanded(
      child: Text("Allow others to contact you through this post",
          style:
          GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.kTextColor)),
    ),
  ]);

  Widget _textField(String label, TextEditingController c,
      {bool description = false}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label),
          SizedBox(height: 12.h),
          CustomTextField(controller: c, isDesription: description),
          SizedBox(height: 24.h),
        ],
      );

  Widget _label(String text) => Text(text,
      style: GoogleFonts.poppins(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.kTextColor));

  /* ───────────────── publish ───────────────── */
  Future<void> _publish() async {
    EasyLoading.show(status: "Please wait…");
    final imageUrls = await postController.uploadImages(selectedImages);

    final notificationService = NotificationService();
    final deviceToken = await notificationService.getDeviceToken();

    await postController.addPostToFirebase(
      uId!,
      provinceC.text.trim(),
      cityC.text.trim(),
      nameC.text.trim(),
      destinationC.text.trim(),
      airlineC.text.trim(),
      startDateC.text.trim(),
      endDateC.text.trim(),
      experienceC.text.trim(),
      imageUrls,
      tags, // <-- List<String>
      allowContact,
      deviceToken,
      status,
      locationName,
    );
    EasyLoading.dismiss();
  }
}
