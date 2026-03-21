import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chronogram/modal/user_detail_modal.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:chronogram/screens/home_screen_provider/home_screen_provider.dart';
import 'package:chronogram/widgets/token_image.dart';
import 'package:chronogram/service/api_service.dart';

class VideoScreen extends StatefulWidget {
  final UserDetailModal? user;
  final String? userName;
  const VideoScreen({super.key, this.user, this.userName});
  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> with WidgetsBindingObserver {
  List<AssetEntity> _mediaList = [];
  List<String> _groupOrder = [];
  Map<String, List<AssetEntity>> _groupedVideos = {};
  List<AssetPathEntity> _albums = [];
  AssetPathEntity? _selectedAlbum;
  bool _isLoading = false;
  bool _isFetchingMore = false;
  int _currentPage = 0;
  final int _pageSize = 60;
  bool _hasMore = true;
  bool _permissionDenied = false;
  int _totalVideoCount = 0; 
  int _totalDeviceVideoCount = 0; 
  final ScrollController _folderScrollController = ScrollController();

  bool _isSyncing = false;
  int _syncedCount = 0;
  int _syncTotal = 0;
  Set<String> _syncedAssetIds = {};

  static const String _syncedIdsKey = "synced_video_asset_ids";
  static const String _syncedCountKey = "synced_video_total_count";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSyncedIds();
    _fetchVideos();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _folderScrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _permissionDenied) _fetchVideos();
  }

  Future<void> _loadSyncedIds() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedIds = prefs.getStringList(_syncedIdsKey) ?? [];
    final int savedCount = prefs.getInt(_syncedCountKey) ?? 0;
    
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(onlyAll: true, type: RequestType.video);
    int deviceTotal = 0;
    if (albums.isNotEmpty) deviceTotal = await albums[0].assetCountAsync;

    if (mounted) {
      setState(() {
        _syncedCount = savedCount;
        _syncedAssetIds = savedIds.toSet();
        _totalDeviceVideoCount = deviceTotal;
      });
    }
  }

  Future<void> _saveSyncedIds(Set<String> ids, int totalCount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_syncedIdsKey, ids.toList());
    await prefs.setInt(_syncedCountKey, totalCount);
  }

  Future<void> _startSync() async {
    if (_isSyncing) return;
    
    if (_albums.isEmpty) {
      final List<AssetPathEntity> allPaths = await PhotoManager.getAssetPathList(type: RequestType.video);
      if (allPaths.isNotEmpty) {
        setState(() => _albums = allPaths);
      }
    }

    AssetPathEntity? allAlbum;
    try {
      allAlbum = _albums.firstWhere((p) => p.isAll);
    } catch (_) {
      if (_albums.isNotEmpty) allAlbum = _albums.first;
    }

    if (allAlbum == null) {
      _showInfoSnackBar("📂 Video gallery nahi mili.");
      return;
    }

    _showSyncProgressDialog(message: "Scanning videos...");
    
    final int totalOnDevice = await allAlbum.assetCountAsync;
    final List<AssetEntity> allMedia = await allAlbum.getAssetListRange(start: 0, end: totalOnDevice);

    final List<AssetEntity> unsynced =
        allMedia.where((a) => !_syncedAssetIds.contains(a.id)).toList();

    if (unsynced.isEmpty) {
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      _showInfoSnackBar("✅ Sab videos pehle se sync hain! ($_syncedCount synced)");
      return;
    }

    setState(() { _isSyncing = true; _syncTotal = unsynced.length; });
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
    _showSyncProgressDialog();

    final List<File> allFiles = [];
    final List<String> allIds = [];
    int collectFail = 0;

    for (final asset in unsynced) {
      try {
        final file = await asset.file;
        if (file != null && await file.exists()) {
          allFiles.add(file);
          allIds.add(asset.id);
        } else { collectFail++; }
      } catch (_) { collectFail++; }
    }

    int successCount = 0;
    int failCount = collectFail;
    final Set<String> newlySyncedIds = {};

    if (allFiles.isNotEmpty) {
      final result = await ApiService.uploadVideosBulk(files: allFiles);
      if (result["status"] == "success") {
        final int uploaded = result["uploaded"] as int? ?? 0;
        successCount = uploaded;
        failCount += allFiles.length - uploaded;
        for (int j = 0; j < uploaded && j < allIds.length; j++) {
          newlySyncedIds.add(allIds[j]);
        }
      } else {
        failCount += allFiles.length;
      }
    }

    final Set<String> updatedIds = {..._syncedAssetIds, ...newlySyncedIds};
    final int updatedTotal = _syncedCount + successCount;
    await _saveSyncedIds(updatedIds, updatedTotal);

    if (mounted) {
      setState(() {
        _syncedAssetIds = updatedIds;
        _syncedCount = updatedTotal;
        _isSyncing = false;
        _syncTotal = 0;
      });
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      _showSyncResultSnackBar(successCount, failCount);
    }
  }

  void _showSyncProgressDialog({String message = "Syncing Videos..."}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: const Color(0xff1A1A1A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const CircularProgressIndicator(color: Colors.orange),
              const SizedBox(height: 20),
              Text(message,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (_syncTotal > 0)
                Text("$_syncTotal videos upload ho rahe hain",
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                  textAlign: TextAlign.center),
              const SizedBox(height: 4),
              const Text("Please wait, app band mat karo",
                style: TextStyle(color: Colors.white38, fontSize: 11),
                textAlign: TextAlign.center),
            ]),
          ),
        ),
      ),
    );
  }

  void _showSyncResultSnackBar(int success, int failed) {
    if (!mounted) return;
    final bool hasFailures = failed > 0;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        hasFailures ? "✅ $success sync hue | ❌ $failed fail" : "🎉 $success videos sync ho gaye!",
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      backgroundColor: hasFailures ? Colors.orange[800] : Colors.green[700],
      duration: const Duration(seconds: 4),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(12),
    ));
  }

  void _showInfoSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      backgroundColor: const Color(0xff2A2A2A),
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(12),
    ));
  }

  Future<void> _fetchVideos() async {
    if (_currentPage == 0) {
      if (mounted) setState(() { _isLoading = true; _permissionDenied = false; });
    } else {
      if (mounted) setState(() => _isFetchingMore = true);
    }

    try {
      final PermissionState ps = await PhotoManager.requestPermissionExtend()
          .timeout(const Duration(seconds: 15), onTimeout: () => PermissionState.denied);

      if (ps.isAuth) {
        if (mounted) setState(() => _permissionDenied = false);

        if (_albums.isEmpty) {
          final filterOption = FilterOptionGroup()
            ..setOption(AssetType.video, const FilterOption(needTitle: true))
            ..orders.add(const OrderOption(type: OrderOptionType.createDate, asc: false));

          final List<AssetPathEntity> allPaths = await PhotoManager.getAssetPathList(
            type: RequestType.video, filterOption: filterOption,
          );
          
          allPaths.sort((a, b) {
            if (a.isAll) return -1;
            if (b.isAll) return 1;
            final nameA = a.name.toLowerCase();
            final nameB = b.name.toLowerCase();
            int getPriority(String name) {
              if (name.contains("camera") || name == "dcim") return 1;
              if (name.contains("whatsapp")) return 2;
              return 100;
            }
            int pA = getPriority(nameA);
            int pB = getPriority(nameB);
            if (pA != pB) return pA.compareTo(pB);
            return nameA.compareTo(nameB);
          });

          if (mounted) {
            final int deviceCount = await allPaths.firstWhere((p) => p.isAll).assetCountAsync;
            setState(() {
              _albums = allPaths;
              _totalDeviceVideoCount = deviceCount;
              if (_selectedAlbum == null && allPaths.isNotEmpty) {
                _selectedAlbum = allPaths.firstWhere((p) => p.isAll, orElse: () => allPaths.first);
              }
            });
          }
        }

        if (_selectedAlbum != null) {
          if (_currentPage == 0) {
            final int total = await _selectedAlbum!.assetCountAsync;
            if (mounted) setState(() => _totalVideoCount = total);
          }

          final List<AssetEntity> entities =
              await _selectedAlbum!.getAssetListPaged(page: _currentPage, size: _pageSize);
          
          if (mounted) {
            setState(() {
              if (_currentPage == 0) {
                _mediaList = entities;
                _groupVideosByDate(entities, clear: true);
              } else {
                _mediaList.addAll(entities);
                _groupVideosByDate(entities, clear: false);
              }
              _hasMore = entities.length == _pageSize;
              _isLoading = false;
              _isFetchingMore = false;
            });
          }
        } else {
          if (mounted) setState(() { _isLoading = false; _isFetchingMore = false; _hasMore = false; _groupedVideos = {}; });
        }
      } else {
        if (mounted) setState(() { _isLoading = false; _isFetchingMore = false; _permissionDenied = true; });
      }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _isFetchingMore = false; });
    }
  }

  void _groupVideosByDate(List<AssetEntity> list, {required bool clear}) {
    if (clear) {
      _groupedVideos.clear();
      _groupOrder.clear();
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final lastWeek = today.subtract(const Duration(days: 7));

    for (var asset in list) {
      final date = asset.createDateTime.toLocal();
      final assetDate = DateTime(date.year, date.month, date.day);
      String group;
      if (assetDate == today) group = "TODAY";
      else if (assetDate == yesterday) group = "YESTERDAY";
      else if (assetDate.isAfter(lastWeek)) group = DateFormat('EEEE').format(date).toUpperCase();
      else if (assetDate.year == now.year) group = DateFormat('MMMM d').format(date).toUpperCase();
      else group = DateFormat('MMMM yyyy').format(date).toUpperCase();

      if (!_groupedVideos.containsKey(group)) {
        _groupedVideos[group] = [];
        if (!_groupOrder.contains(group)) _groupOrder.add(group);
      }
      _groupedVideos[group]!.add(asset);
    }
  }

  void _playVideo(AssetEntity asset) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => FullScreenVideoViewer(assets: _mediaList, initialIndex: _mediaList.indexOf(asset)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(children: [
          _buildPremiumHeader(),
          const Divider(color: Colors.white12, height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                : _permissionDenied
                ? _buildPermissionDeniedView()
                : _groupedVideos.isEmpty
                ? _buildNoMediaView()
                : NotificationListener<ScrollNotification>(
                    onNotification: (scrollInfo) {
                      if (!_isFetchingMore && _hasMore &&
                          scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 500) {
                        _currentPage++;
                        _fetchVideos();
                      }
                      return true;
                    },
                    child: CustomScrollView(
                      cacheExtent: 500,
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      slivers: [
                        SliverToBoxAdapter(child: _buildFolderBar()),
                        SliverToBoxAdapter(child: _buildAllVideosSummary()),
                        ..._groupOrder.map((groupKey) {
                          final assets = _groupedVideos[groupKey]!;
                          return SliverMainAxisGroup(slivers: [
                            SliverPersistentHeader(pinned: true, delegate: _StickyHeaderDelegate(title: groupKey)),
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                              sliver: SliverGrid(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3, crossAxisSpacing: 6, mainAxisSpacing: 6,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final asset = assets[index];
                                    final bool isSynced = _syncedAssetIds.contains(asset.id);
                                    return KeyedSubtree(
                                      key: ValueKey(asset.id),
                                      child: _SmoothClick(
                                        onTap: () => _playVideo(asset),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Stack(fit: StackFit.expand, children: [
                                            _GridThumbnail(asset: asset),
                                            Center(
                                              child: Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: Colors.black38, shape: BoxShape.circle,
                                                  border: Border.all(color: Colors.white70, width: 1.5),
                                                ),
                                                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 4, right: 6,
                                              child: Text(_formatDuration(asset.duration),
                                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold,
                                                  shadows: [Shadow(color: Colors.black, blurRadius: 4)])),
                                            ),
                                            if (isSynced)
                                              Positioned(
                                                bottom: 4, left: 4,
                                                child: Container(
                                                  width: 14, height: 14,
                                                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                                                  child: const Icon(Icons.check, color: Colors.white, size: 9),
                                                ),
                                              ),
                                          ]),
                                        ),
                                      ),
                                    );
                                  },
                                  childCount: assets.length,
                                ),
                              ),
                            ),
                          ]);
                        }).toList(),
                        if (_isFetchingMore)
                          const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(20),
                            child: Center(child: CircularProgressIndicator(color: Colors.orange, strokeWidth: 2)))),
                        const SliverToBoxAdapter(child: SizedBox(height: 80)),
                      ],
                    ),
                  ),
          ),
        ]),
      ),
    );
  }

  Widget _buildPremiumHeader() {
    final String name = widget.userName ?? "User";
    final int totalCount = _totalDeviceVideoCount;
    final bool allSynced = totalCount > 0 && totalCount <= _syncedCount;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05), width: 1)),
      ),
      child: Row(children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle, border: Border.all(color: Colors.orange, width: 1.5),
            color: Colors.white.withOpacity(0.05),
          ),
          child: ClipOval(
            child: context.watch<HomeScreenProvider>().profileUrl != null
                ? TokenImage(
                    imageUrl: context.watch<HomeScreenProvider>().profileUrlSmall ?? context.watch<HomeScreenProvider>().profileUrl!,
                    fit: BoxFit.cover,
                  )
                : Center(child: Text(_getInitials(name), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text("$totalCount videos • $_syncedCount synced", style: const TextStyle(color: Colors.white54, fontSize: 11)),
        ])),
        GestureDetector(
          onTap: _isSyncing ? null : _startSync,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: allSynced ? Colors.green.withOpacity(0.15) : Colors.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: allSynced ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3), width: 1),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (_isSyncing)
                const SizedBox(width: 10, height: 10, child: CircularProgressIndicator(color: Colors.orange, strokeWidth: 1.5))
              else
                Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: allSynced ? Colors.green : Colors.orange)),
              const SizedBox(width: 6),
              Text(
                _isSyncing ? "Syncing..." : allSynced ? "All Synced ✓" : "Sync Now",
                style: TextStyle(color: allSynced ? Colors.green : Colors.orange, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ]),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () { _currentPage = 0; _fetchVideos(); },
          icon: const Icon(Icons.refresh, color: Colors.white70, size: 20),
          constraints: const BoxConstraints(), padding: EdgeInsets.zero,
        ),
      ]),
    );
  }

  Widget _buildFolderBar() {
    if (_albums.isEmpty) return const SizedBox.shrink();
    return Container(
      height: 60, padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        controller: _folderScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _albums.length,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemBuilder: (context, index) {
          final album = _albums[index];
          final isSelected = _selectedAlbum?.id == album.id;
          return GestureDetector(
            onTap: () {
              setState(() { _selectedAlbum = album; _currentPage = 0; _fetchVideos(); });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.orange : Colors.white10,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? Colors.orange : Colors.white24),
              ),
              child: Center(
                child: Text(album.name == "Recent" ? "All" : album.name,
                  style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAllVideosSummary() {
    if (_totalVideoCount == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 5),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text("ALL VIDEOS", style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        Text("$_totalVideoCount items", style: const TextStyle(color: Colors.white24, fontSize: 11)),
      ]),
    );
  }

  Widget _buildNoMediaView() {
    return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.videocam_off_outlined, color: Colors.white12, size: 60),
      SizedBox(height: 15),
      Text("No Videos Found", style: TextStyle(color: Colors.white38, fontSize: 16)),
    ]));
  }

  Widget _buildPermissionDeniedView() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.lock_outline, color: Colors.white24, size: 60),
      const SizedBox(height: 20),
      const Text("Gallery Access Required", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 30),
      ElevatedButton(onPressed: () => PhotoManager.openSetting(), child: const Text("Open Settings")),
    ]));
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return "U";
    List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  String _formatDuration(int duration) {
    int minutes = duration ~/ 60;
    int seconds = duration % 60;
    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }
}

class _GridThumbnail extends StatelessWidget {
  final AssetEntity asset;
  const _GridThumbnail({required this.asset});
  @override
  Widget build(BuildContext context) {
    return AssetEntityImage(
      asset, isOriginal: false, thumbnailSize: const ThumbnailSize.square(250), fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xff121212), child: const Icon(Icons.videocam_off_outlined, color: Colors.white24)),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  _StickyHeaderDelegate({required this.title});
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(height: 40, color: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 15), alignment: Alignment.centerLeft,
      child: Text(title, style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5)));
  }
  @override double get maxExtent => 40;
  @override double get minExtent => 40;
  @override bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) => title != oldDelegate.title;
}

class _SmoothClick extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _SmoothClick({required this.child, this.onTap});
  @override State<_SmoothClick> createState() => _SmoothClickState();
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
      child: AnimatedScale(scale: _isPressed ? 0.96 : 1.0, duration: const Duration(milliseconds: 100), child: widget.child),
    );
  }
}

class FullScreenVideoViewer extends StatefulWidget {
  final List<AssetEntity> assets;
  final int initialIndex;
  const FullScreenVideoViewer({super.key, required this.assets, required this.initialIndex});
  @override State<FullScreenVideoViewer> createState() => _FullScreenVideoViewerState();
}

class _FullScreenVideoViewerState extends State<FullScreenVideoViewer> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showAppBar = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _pageController.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asset = widget.assets[_currentIndex];
    final date = asset.createDateTime.toLocal();
    final formattedDate = DateFormat('dd MMM yyyy').format(date);
    final formattedTime = DateFormat('hh:mm a').format(date);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _showAppBar ? AppBar(
        backgroundColor: Colors.black.withOpacity(0.45),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        title: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Text(formattedDate, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(formattedTime, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ]),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: const Color(0xff121212),
            onSelected: (value) {
              if (value == 'Details') _showVideoDetails(asset);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Details', child: Text('More Details', style: TextStyle(color: Colors.white))),
            ],
          ),
        ],
      ) : null,
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.assets.length,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemBuilder: (context, index) => _SingleVideoPlayer(
          asset: widget.assets[index],
          onToggleControls: (visible) => setState(() => _showAppBar = visible),
        ),
      ),
    );
  }

  void _showVideoDetails(AssetEntity asset) async {
    final file = await asset.file;
    int fileSize = 0;
    String filePath = "Unavailable";
    if (file != null) {
      fileSize = await file.length();
      filePath = file.path;
    }
    final date = asset.createDateTime.toLocal();
    final formattedDate = DateFormat('dd MMM yyyy').format(date);
    final formattedTime = DateFormat('hh:mm a').format(date);
    final fileName = asset.title ?? "Unknown";
    final sizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);
    final duration = _formatDuration(asset.duration);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: Text("Video Details", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 20),
            _detailRow("Name:", fileName),
            _detailRow("Date:", formattedDate),
            _detailRow("Time:", formattedTime),
            _detailRow("Duration:", duration),
            _detailRow("Resolution:", "${asset.width} × ${asset.height}"),
            _detailRow("Size:", "$sizeMB MB"),
            _detailRow("Source:", _getVideoSource(filePath)),
            _detailRow("Path:", filePath),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(title, style: const TextStyle(color: Colors.white54, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 13))),
        ],
      ),
    );
  }

  String _getVideoSource(String path) {
    final p = path.toLowerCase();
    if (p.contains('whatsapp')) return '💬 WhatsApp';
    if (p.contains('telegram')) return '✈️ Telegram';
    if (p.contains('instagram')) return '📸 Instagram';
    if (p.contains('screenshot')) return '📷 Screen Record';
    if (p.contains('download')) return '🌐 Downloaded';
    if (p.contains('dcim/camera')) return '📹 Camera';
    if (p.contains('dcim')) return '📹 Camera Roll';
    return '📁 Other';
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return "$minutes:${remainingSeconds.toString().padLeft(2, '0')}";
  }
}

class _SingleVideoPlayer extends StatefulWidget {
  final AssetEntity asset;
  final Function(bool)? onToggleControls;
  const _SingleVideoPlayer({required this.asset, this.onToggleControls});
  @override State<_SingleVideoPlayer> createState() => _SingleVideoPlayerState();
}

class _SingleVideoPlayerState extends State<_SingleVideoPlayer> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _showControls = true;

  @override
  void initState() { super.initState(); _initVideo(); }

  @override
  void didUpdateWidget(_SingleVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asset.id != widget.asset.id) {
       _initialized = false;
       _controller?.dispose();
       _initVideo();
    }
  }

  Future<void> _initVideo() async {
    final file = await widget.asset.file;
    if (file != null && mounted) {
      _controller = VideoPlayerController.file(file);
      await _controller!.initialize();
      if (mounted) { 
        setState(() => _initialized = true); 
        _controller!.play(); 
        _controller!.setLooping(true); 
        _hideControlsAutomatically();
      }
    }
  }

  void _hideControlsAutomatically() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && _controller != null && _controller!.value.isPlaying && _showControls) {
        setState(() {
          _showControls = false;
          widget.onToggleControls?.call(false);
        });
      }
    });
  }

  @override
  void dispose() { _controller?.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) return const Center(child: CircularProgressIndicator(color: Colors.orange));
    return GestureDetector(
      onTap: () {
        setState(() {
          _showControls = !_showControls;
          widget.onToggleControls?.call(_showControls);
        });
        if (_showControls) _hideControlsAutomatically();
      },
      child: Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(aspectRatio: _controller!.value.aspectRatio, child: VideoPlayer(_controller!)),
            if (_showControls)
              Container(
                decoration: const BoxDecoration(color: Colors.black26),
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                         _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle, border: Border.all(color: Colors.white24, width: 1)),
                      child: Icon(_controller!.value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 55),
                    ),
                  ),
                ),
              ),
            if (_showControls)
              Positioned(
                bottom: 50, left: 20, right: 20,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ValueListenableBuilder(
                      valueListenable: _controller!,
                      builder: (context, VideoPlayerValue value, child) {
                         return Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             Text(_formatDuration(value.position.inSeconds), style: const TextStyle(color: Colors.white, fontSize: 11)),
                             Text(_formatDuration(value.duration.inSeconds), style: const TextStyle(color: Colors.white, fontSize: 11)),
                           ],
                         );
                      },
                    ),
                    const SizedBox(height: 5),
                    VideoProgressIndicator(
                      _controller!, 
                      allowScrubbing: true, 
                      colors: const VideoProgressColors(playedColor: Colors.orange, bufferedColor: Colors.white38, backgroundColor: Colors.white10),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return "$minutes:${remainingSeconds.toString().padLeft(2, '0')}";
  }
}
