import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:roam_the_world_app/pages/airline/airline_screen.dart';
import 'package:roam_the_world_app/pages/chat/chat_screen.dart';
import 'package:roam_the_world_app/pages/home/home_screen.dart';
import 'package:roam_the_world_app/pages/main/controller/main_controller.dart';
import 'package:roam_the_world_app/pages/map/map_screen.dart';
import 'package:roam_the_world_app/pages/profile/profile_screen.dart';
import 'package:roam_the_world_app/services/Notifiction-Service.dart';
import 'package:roam_the_world_app/utils/app_colors.dart';

import '../Utills/UserRepository.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final NotificationService _notificationService = NotificationService();
  final UserRepository _userRepo = UserRepository();

  String _fullName = 'Guest';           // ← state field

  @override
  void initState() {
    super.initState();
    _loadUserProfile();

    if (!Get.isRegistered<MainController>()) {
      Get.put(MainController());
    }

    _notificationService.getDeviceToken();
    _notificationService.requestNotificationService();
  }

  Future<void> _loadUserProfile() async {
    final data = await _userRepo.fetchCurrentUserDoc();
    if (data == null) return;

    setState(() {
      _fullName = data['fullname'] ?? 'No name';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('No user signed in')),
      );
    }

    return GetBuilder<MainController>(
      builder: (controller) => Scaffold(
        backgroundColor: AppColors.kBackgroundColor,
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: AppColors.kBackgroundColor,
          showUnselectedLabels: true,
          showSelectedLabels: true,
          currentIndex: controller.selectedIndex,
          selectedItemColor: AppColors.primaryColor,
          type: BottomNavigationBarType.fixed,
          onTap: (i) => controller.changeTabIndex(i, context),
          items: controller.icons.map((iconPath) {
            final idx = controller.icons.indexOf(iconPath);
            return BottomNavigationBarItem(
              icon: SvgPicture.asset(
                iconPath,
                color: idx == controller.selectedIndex
                    ? AppColors.primaryColor
                    : null,
              ),
              label: controller.names[idx],
            );
          }).toList(),
        ),
        body: IndexedStack(
          index: controller.selectedIndex,
          children: [
            const HomeScreen(),
            const MapScreen(),
            const AirlineScreen(),
            // pass the value we fetched
            ChatScreen(currentUsername: _fullName),
            const ProfileScreen(),
          ],
        ),
      ),
    );
  }
}
