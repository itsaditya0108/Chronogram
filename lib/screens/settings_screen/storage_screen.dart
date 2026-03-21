import 'package:chronogram/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chronogram/screens/home_screen_provider/home_screen_provider.dart';
import 'package:photo_manager/photo_manager.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});
  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch latest storage info when entering
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeScreenProvider>().fetchStorageUsage();
      context.read<HomeScreenProvider>().fetchStorageDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeScreenProvider>();
    final used = provider.storageUsed;
    final limit = provider.storageLimit;
    final photos = provider.photosStorage;
    final videos = provider.videosStorage;
    final isLoading = provider.isStorageLoading;

    final fraction = limit > 0 ? (used / limit).clamp(0.0, 1.0) : 0.0;
    final isWarning = (used / limit) >= 0.9;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Storage",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                children: [
                  /// Storage Usage Overview
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xff121212),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xff3B260D),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: const Icon(
                            Icons.sd_storage_outlined,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Storage Usage",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "${used.toStringAsFixed(1)} GB of ${limit.toStringAsFixed(0)} GB used",
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Stack(
                                children: [
                                  Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.white12,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: fraction,
                                    child: Container(
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: isWarning
                                            ? Colors.redAccent
                                            : Colors.orange,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Breakdown
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xff121212),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      children: [
                        _buildStorageItem(
                          "Photos",
                          '${photos.toStringAsFixed(1)} GB',
                          limit > 0 ? (photos / limit).clamp(0.0, 1.0) : 0.0,
                        ),
                        const Divider(color: Colors.white12, height: 1),
                        _buildStorageItem(
                          "Videos",
                          '${videos.toStringAsFixed(1)} GB',
                          limit > 0 ? (videos / limit).clamp(0.0, 1.0) : 0.0,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// Local Cache Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xff121212),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Local Media Cache",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Temporary thumbnails and cached media stored on your phone. Clearing this will free up local space but may cause media to load slower next time.",
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        const SizedBox(height: 20),
                        _SmoothClick(
                          onTap: () async {
                            // Clear photo_manager's disk cache for thumbnails
                            await PhotoManager.clearFileCache();
                            // Clear Flutter's in-memory image cache
                            PaintingBinding.instance.imageCache.clear();
                            PaintingBinding.instance.imageCache.clearLiveImages();
                            
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Media cache cleared successfully!"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.orange, width: 1),
                            ),
                            child: const Center(
                              child: Text(
                                "Clear Media Cache",
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildStorageItem(String title, String size, double fraction) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                size,
                style: const TextStyle(color: Colors.white60, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              FractionallySizedBox(
                widthFactor: fraction,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmoothClick extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _SmoothClick({required this.child, this.onTap});
  @override
  State<_SmoothClick> createState() => _SmoothClickState();
}

class _SmoothClickState extends State<_SmoothClick> {
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}
