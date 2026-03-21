import 'dart:io';
import 'package:chronogram/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:chronogram/modal/user_detail_modal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:chronogram/screens/home_screen_provider/home_screen_provider.dart';
import 'package:chronogram/widgets/token_image.dart';
import 'dart:async';
import 'package:chronogram/service/image_api_client.dart';
import 'package:image_cropper/image_cropper.dart';

class ViewProfileScreen extends StatefulWidget {
  final UserDetailModal? user;
  final String userName;

  const ViewProfileScreen({super.key, this.user, required this.userName});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  File? _profileImage;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeScreenProvider>().fetchProfileHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Profile Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            /// Profile Picture Avatar with Glow
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Colors.orange.shade700, Colors.orange.shade400],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 53,
                        backgroundColor: Colors.orange,
                        child: ClipOval(
                          child: Container(
                            width: 102,
                            height: 102,
                            color: const Color(0xff1A1A1A),
                            child: context.watch<HomeScreenProvider>().isProfileLoading
                                ? const Center(child: CircularProgressIndicator(color: Colors.orange, strokeWidth: 2))
                                : context.watch<HomeScreenProvider>().profileUrl != null
                                    ? TokenImage(
                                        imageUrl: context.watch<HomeScreenProvider>().profileUrl!,
                                        fit: BoxFit.cover,
                                      )
                                    : Center(
                                        child: Text(
                                          _getInitials(widget.user?.name ?? "U"),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 30,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: _pickAndUploadImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 2.5),
                            ),
                            child: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Member Since 2024",
                    style: TextStyle(color: Colors.white38, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 45),

            /// INFO LIST
            _buildInfoTile(
              icon: Icons.person_outline_rounded,
              title: "Full Name",
              value: widget.userName,
            ),
            _buildInfoTile(
              icon: Icons.cake_outlined,
              title: "Date of Birth",
              value: widget.user?.dob ?? "Not set",
            ),
            _buildInfoTile(
              icon: Icons.email_outlined,
              title: "Email Address",
              value: _maskEmail(widget.user?.email ?? "no-email@chronogram.com"),
              isLocked: true,
            ),
            _buildInfoTile(
              icon: Icons.phone_android_outlined,
              title: "Phone Number",
              value: _maskPhone(widget.user?.mobileNumber ?? "Not verified"),
              isLocked: true,
            ),

            const SizedBox(height: 30),

            /// PROFILE HISTORY
            _buildHistorySection(),

            const SizedBox(height: 40),

            /// SECURITY NOTE
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, color: Colors.orange, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "To update your verified email or phone, please contact support for security reasons.",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() {
        _isUploading = true;
      });
      
      // ✂️ Image Cropping
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), // Square
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Profile Photo',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: Colors.orange,
            statusBarColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false, // Allow resetting to other ratios if needed
            backgroundColor: Colors.black,
          ),
          IOSUiSettings(
            title: 'Crop Profile Photo',
            aspectRatioLockEnabled: true,
            resetButtonHidden: false, // Already exists on iOS
          ),
        ],
      );

      if (croppedFile == null) {
        setState(() => _isUploading = false);
        return;
      }

      _profileImage = File(croppedFile.path);
      final result = await context.read<HomeScreenProvider>().uploadProfilePicture(_profileImage!);
      
      if (mounted) {
        setState(() => _isUploading = false);
        if (result["status"] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile photo updated successfully")));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result["message"] ?? "Upload failed"), backgroundColor: Colors.redAccent),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    bool isLocked = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xff1A1A1A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.orange.shade400, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (isLocked)
            const Icon(Icons.lock_outline_rounded, color: Colors.white24, size: 18)
          else
            const Icon(Icons.chevron_right_rounded, color: Colors.white24, size: 20),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return "U";
    List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  String _maskEmail(String email) {
    if (!email.contains('@')) return email;
    List<String> parts = email.split('@');
    String namePart = parts[0];
    String domainPart = parts[1];
    if (namePart.length <= 2) return email;
    String maskedName = namePart.substring(0, 2) + '*' * (namePart.length - 2) + namePart.substring(namePart.length - 1);
    return '$maskedName@$domainPart';
  }

  String _maskPhone(String phone) {
    if (phone.length < 6) return phone;
    String visibleStart = phone.substring(0, 3);
    String visibleEnd = phone.substring(phone.length - 3);
    String maskedMiddle = '*' * (phone.length - 6);
    return '$visibleStart $maskedMiddle $visibleEnd';
  }

  Widget _buildHistorySection() {
    final history = context.watch<HomeScreenProvider>().profileHistory;
    if (history.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Profile History",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];
              final isActive = item['active'] == true;

              return GestureDetector(
                onTap: isActive ? null : () => _showSelectPhotoDialog(item),
                child: Container(
                  width: 90,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isActive ? Colors.orange : Colors.white10,
                      width: isActive ? 2 : 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (item['mediumPath'] != null)
                          TokenImage(
                            imageUrl: ApiService.getImageUrl(item['mediumPath']),
                            fit: BoxFit.cover,
                          )
                        else
                          const Center(
                            child: Icon(Icons.person, color: Colors.white24),
                          ),
                        if (isActive)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
        ),
      ),
    ],
  );
}

  void _showSelectPhotoDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff1A1A1A),
        title: const Text("Set Profile Picture", style: TextStyle(color: Colors.white)),
        content: const Text("Kyun aap is photo ko fir se profile picture banana chahte hain?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Nahi", style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<HomeScreenProvider>().setActiveProfilePicture(item['id']);
            },
            child: const Text("Haan", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
