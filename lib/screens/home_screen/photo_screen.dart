import 'dart:io';
import 'dart:typed_data';
import 'package:chronogram/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:chronogram/modal/user_detail_modal.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:chronogram/screens/home_screen_provider/home_screen_provider.dart';
import 'package:chronogram/widgets/token_image.dart';

class PhotoScreen extends StatefulWidget {
  final UserDetailModal? user;
  final String? userName;
  const PhotoScreen({super.key, this.user, this.userName});
  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> with WidgetsBindingObserver {
  List<AssetEntity> _mediaList = [];
  List<String> _groupOrder = [];
  Map<String, List<AssetEntity>> _groupedMedia = {};
  List<AssetPathEntity> _albums = [];
  AssetPathEntity? _selectedAlbum;
  bool _isLoading = false;
  bool _isFetchingMore = false;
  int _currentPage = 0;
  final int _pageSize = 80;
  bool _hasMore = true;
  bool _permissionDenied = false;
  int _totalPhotoCount = 0; // Currently selected album count
  int _totalDevicePhotoCount = 0; // Total count of images on device
  final ScrollController _folderScrollController = ScrollController();

  bool _isSyncing = false;
  int _syncedCount = 0;
  int _syncTotal = 0;
  Set<String> _syncedAssetIds = {};

  static const String _syncedIdsKey = "synced_asset_ids";
  static const String _syncedCountKey = "synced_total_count";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSyncedIds();
    _fetchPhotos();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _folderScrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _permissionDenied) _fetchPhotos();
  }

  Future<void> _loadSyncedIds() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedIds = prefs.getStringList(_syncedIdsKey) ?? [];
    final int savedCount = prefs.getInt(_syncedCountKey) ?? 0;
    
    // Also fetch real-time device totals
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(onlyAll: true, type: RequestType.image);
    int deviceTotal = 0;
    if (albums.isNotEmpty) deviceTotal = await albums[0].assetCountAsync;

    if (mounted) {
      setState(() {
        _syncedCount = savedCount;
        _syncedAssetIds = savedIds.toSet();
        _totalDevicePhotoCount = deviceTotal;
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
    
    // Ensure albums are loaded
    if (_albums.isEmpty) {
      final List<AssetPathEntity> allPaths = await PhotoManager.getAssetPathList(type: RequestType.image);
      if (allPaths.isNotEmpty) {
        setState(() => _albums = allPaths);
      }
    }

    // Find the 'All' album to sync everything
    AssetPathEntity? allAlbum;
    try {
      allAlbum = _albums.firstWhere((p) => p.isAll);
    } catch (_) {
      if (_albums.isNotEmpty) allAlbum = _albums.first;
    }

    if (allAlbum == null) {
      _showInfoSnackBar("📂 Gallery sync karne ke liye nahi mili.");
      return;
    }

    _showSyncProgressDialog(message: "Scanning library...");
    
    // Fetch a large chunk of all photos (e.g. up to 1000 for MVP, or all if feasible)
    // Actually, we should fetch all asset IDs to compare.
    final int totalOnDevice = await allAlbum.assetCountAsync;
    final List<AssetEntity> allMedia = await allAlbum.getAssetListRange(start: 0, end: totalOnDevice);

    final List<AssetEntity> unsynced =
        allMedia.where((a) => !_syncedAssetIds.contains(a.id)).toList();

    if (unsynced.isEmpty) {
      if (Navigator.of(context).canPop()) Navigator.of(context).pop(); // dismiss scanning
      _showInfoSnackBar("✅ Sab photos pehle se sync hain! ($_syncedCount synced)");
      return;
    }

    setState(() { _isSyncing = true; _syncTotal = unsynced.length; });
    // Update the existing dialog or close and open new one? 
    // Let's just update the UI state and keep the dialog logic.
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
      final result = await ApiService.uploadImagesBulk(files: allFiles);
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

  void _showSyncProgressDialog({String message = "Syncing Photos..."}) {
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
              Text("$_syncTotal photos upload ho rahe hain",
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
        hasFailures ? "✅ $success sync hue | ❌ $failed fail" : "🎉 $success photos sync ho gaye!",
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

  Future<void> _fetchPhotos() async {
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
            ..setOption(
              AssetType.image,
              const FilterOption(
                needTitle: true,
                sizeConstraint: SizeConstraint(ignoreSize: true),
              ),
            )
            ..orders.add(const OrderOption(type: OrderOptionType.createDate, asc: false));

          final List<AssetPathEntity> allPaths = await PhotoManager.getAssetPathList(
            type: RequestType.image, filterOption: filterOption,
          );
          
          // Custom Sorting: Recent > Camera > Screenshots > WhatsApp > Others
          allPaths.sort((a, b) {
            if (a.isAll) return -1;
            if (b.isAll) return 1;
            final nameA = a.name.toLowerCase();
            final nameB = b.name.toLowerCase();
            
            int getPriority(String name) {
              if (name.contains("camera") || name == "dcim") return 1;
              if (name.contains("screenshot")) return 2;
              if (name.contains("whatsapp")) return 3;
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
              _totalDevicePhotoCount = deviceCount;
              if (_selectedAlbum == null && allPaths.isNotEmpty) {
                _selectedAlbum = allPaths.firstWhere((p) => p.isAll, orElse: () => allPaths.first);
              }
            });
          }
        }

        if (_selectedAlbum != null) {
          if (_currentPage == 0) {
            final int total = await _selectedAlbum!.assetCountAsync;
            if (mounted) setState(() => _totalPhotoCount = total);
          }

          final List<AssetEntity> entities =
              await _selectedAlbum!.getAssetListPaged(page: _currentPage, size: _pageSize);
          
          // Ensure Newest First
          entities.sort((a, b) => b.createDateTime.compareTo(a.createDateTime));

          if (mounted) {
            setState(() {
              if (_currentPage == 0) {
                _mediaList = entities;
                _groupPhotosByDate(entities, clear: true);
              } else {
                _mediaList.addAll(entities);
                _groupPhotosByDate(entities, clear: false);
              }
              _hasMore = entities.length == _pageSize;
              _isLoading = false;
              _isFetchingMore = false;
            });
          }
        } else {
          if (mounted) setState(() {
            _isLoading = false; _isFetchingMore = false;
            _hasMore = false; _groupedMedia = {}; _totalPhotoCount = 0;
          });
        }
      } else {
        if (mounted) setState(() {
          _isLoading = false; _isFetchingMore = false; _permissionDenied = true;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _isFetchingMore = false; });
    }
  }

  void _groupPhotosByDate(List<AssetEntity> list, {required bool clear}) {
    if (clear) {
      _groupedMedia.clear();
      _groupOrder.clear();
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final lastWeek = today.subtract(const Duration(days: 7));
    final lastMonth = today.subtract(const Duration(days: 30));

    for (var asset in list) {
      final date = asset.createDateTime.toLocal();
      final assetDate = DateTime(date.year, date.month, date.day);
      String group;
      if (assetDate == today) {
        group = "TODAY";
      } else if (assetDate == yesterday) {
        group = "YESTERDAY";
      } else if (assetDate.isAfter(lastWeek)) {
        group = DateFormat('EEEE').format(date).toUpperCase();
      } else if (assetDate.year == now.year) {
        group = DateFormat('MMMM d').format(date).toUpperCase();
      } else {
        group = DateFormat('MMMM yyyy').format(date).toUpperCase();
      }

      if (!_groupedMedia.containsKey(group)) {
        _groupedMedia[group] = [];
        if (!_groupOrder.contains(group)) {
          _groupOrder.add(group);
        }
      }
      _groupedMedia[group]!.add(asset);
    }
  }

  void _showFullScreenImage(AssetEntity asset) {
    final int index = _mediaList.indexOf(asset);
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => FullScreenImageViewer(
        assets: _mediaList, initialIndex: index < 0 ? 0 : index),
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
                : _groupedMedia.isEmpty
                ? _buildNoMediaView()
                : NotificationListener<ScrollNotification>(
                    onNotification: (scrollInfo) {
                      if (!_isFetchingMore && _hasMore &&
                          scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 500) {
                        _currentPage++;
                        _fetchPhotos();
                      }
                      return true;
                    },
                    child: CustomScrollView(
                      cacheExtent: 500,
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      slivers: [
                        SliverToBoxAdapter(
                          child: _buildFolderBar(),
                        ),
                        SliverToBoxAdapter(
                          child: _buildAllPhotosSummary(),
                        ),
                        ..._groupOrder.map((groupKey) {
                          final assets = _groupedMedia[groupKey]!;
                          return SliverMainAxisGroup(slivers: [
                            SliverPersistentHeader(
                              pinned: true,
                              delegate: _StickyHeaderDelegate(title: groupKey),
                            ),
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                              sliver: SliverGrid(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 3,
                                  mainAxisSpacing: 3,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final asset = assets[index];
                                    final bool isSynced = _syncedAssetIds.contains(asset.id);
                                    return KeyedSubtree(
                                      key: ValueKey(asset.id),
                                      child: _SmoothClick(
                                        onTap: () => _showFullScreenImage(asset),
                                        child: Stack(fit: StackFit.expand, children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(3),
                                            child: _GridThumbnail(asset: asset),
                                          ),
                                          if (asset.type == AssetType.video)
                                            const Positioned(right: 4, top: 4,
                                              child: Icon(Icons.play_circle_fill,
                                                color: Colors.white, size: 16)),
                                          if (isSynced)
                                            Positioned(
                                              bottom: 3, right: 3,
                                              child: Container(
                                                width: 14, height: 14,
                                                decoration: BoxDecoration(
                                                  color: Colors.green.withOpacity(0.9),
                                                  shape: BoxShape.circle),
                                                child: const Icon(Icons.check,
                                                  color: Colors.white, size: 9),
                                              ),
                                            ),
                                        ]),
                                      ),
                                    );
                                  },
                                  childCount: assets.length,
                                  addRepaintBoundaries: true,
                                  addAutomaticKeepAlives: true,
                                ),
                              ),
                            ),
                          ]);
                        }).toList(),
                        if (_isFetchingMore)
                          const SliverToBoxAdapter(
                            child: Padding(padding: EdgeInsets.all(20),
                              child: Center(child: CircularProgressIndicator(
                                color: Colors.orange, strokeWidth: 2))),
                          ),
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
    final int totalCount = _totalDevicePhotoCount;
    final int unsyncedCount = totalCount > 0
        ? (totalCount - _syncedCount).clamp(0, totalCount)
        : 0;
    final bool allSynced = totalCount > 0 && unsyncedCount == 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05), width: 1)),
      ),
      child: Row(children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.orange.withOpacity(0.5), width: 1.5),
            color: Colors.white.withOpacity(0.05),
          ),
          child: ClipOval(
            child: context.watch<HomeScreenProvider>().profileUrl != null
                ? TokenImage(
                    imageUrl: context.watch<HomeScreenProvider>().profileUrlSmall ?? context.watch<HomeScreenProvider>().profileUrl!,
                    fit: BoxFit.cover,
                  )
                : Center(
                    child: Text(_getInitials(name),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(
            color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          if (_totalPhotoCount > 0)
            RichText(text: TextSpan(
              style: const TextStyle(fontSize: 12),
              children: [
                TextSpan(text: "$totalCount photos",
                  style: const TextStyle(color: Colors.white54)),
                if (_syncedCount > 0) ...[
                  const TextSpan(text: "  •  ", style: TextStyle(color: Colors.white24)),
                  TextSpan(text: "$_syncedCount synced",
                    style: const TextStyle(color: Colors.green)),
                ],
                if (unsyncedCount > 0) ...[
                  const TextSpan(text: "  •  ", style: TextStyle(color: Colors.white24)),
                  TextSpan(text: "$unsyncedCount pending",
                    style: const TextStyle(color: Colors.orange)),
                ],
              ],
            ))
          else
            const Text("My Gallery", style: TextStyle(color: Colors.white54, fontSize: 12)),
        ])),
        GestureDetector(
          onTap: _isSyncing ? null : _startSync,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: _isSyncing
                  ? Colors.grey.withOpacity(0.15)
                  : allSynced ? Colors.green.withOpacity(0.15) : Colors.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isSyncing
                    ? Colors.grey.withOpacity(0.3)
                    : allSynced ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
                width: 1),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (_isSyncing)
                const SizedBox(width: 10, height: 10,
                  child: CircularProgressIndicator(color: Colors.grey, strokeWidth: 1.5))
              else
                Container(width: 6, height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: allSynced ? Colors.green : Colors.orange)),
              const SizedBox(width: 6),
              Text(
                _isSyncing ? "Syncing..."
                    : allSynced ? "All Synced ✓"
                    : unsyncedCount > 0 ? "Sync ($unsyncedCount)" : "Sync Now",
                style: TextStyle(
                  color: _isSyncing ? Colors.grey : allSynced ? Colors.green : Colors.orange,
                  fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ]),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () { _currentPage = 0; _fetchPhotos(); },
          icon: const Icon(Icons.refresh, color: Colors.white70, size: 20),
          constraints: const BoxConstraints(), padding: EdgeInsets.zero,
        ),
      ]),
    );
  }

  Widget _buildPermissionDeniedView() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.lock_outline, color: Colors.white24, size: 60),
      const SizedBox(height: 20),
      const Text("Gallery Access Denied",
        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text("Please grant permissions to see your media",
        style: TextStyle(color: Colors.white54)),
      const SizedBox(height: 30),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        ElevatedButton(
          onPressed: () { _currentPage = 0; _fetchPhotos(); },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white10, foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
          child: const Text("Try Again")),
        const SizedBox(width: 15),
        ElevatedButton(
          onPressed: () => PhotoManager.openSetting(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange, foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
          child: const Text("Open Settings")),
      ]),
    ]));
  }

  Widget _buildNoMediaView() {
    return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.photo_library_outlined, color: Colors.white12, size: 60),
      SizedBox(height: 15),
      Text("No Photos Found", style: TextStyle(color: Colors.white38, fontSize: 16)),
    ]));
  }

  Widget _buildFolderBar() {
    if (_albums.isEmpty) return const SizedBox.shrink();
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        key: const PageStorageKey("folder_list"),
        controller: _folderScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _albums.length,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemBuilder: (context, index) {
          final album = _albums[index];
          final isSelected = _selectedAlbum?.id == album.id;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedAlbum = album;
                _currentPage = 0;
                _fetchPhotos();
              });
              // Only scroll if item is likely not well-positioned
              if (index > 2) {
                 _folderScrollController.animateTo(
                  (index - 1) * 85.0, // Bring to somewhat left but not starting edge
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                );
              } else {
                 _folderScrollController.animateTo(
                  0, // Back to start for first few items
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                );
              }
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
                child: Text(
                  album.name == "Recent" ? "All" : album.name,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAllPhotosSummary() {
    if (_totalPhotoCount == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "ALL PHOTOS",
            style: TextStyle(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          Text(
            "$_totalPhotoCount items",
            style: const TextStyle(
              color: Colors.white24,
              fontSize: 11,
            ),
          ),
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
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  _StickyHeaderDelegate({required this.title});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: 40,
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.orange,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  @override
  double get maxExtent => 40;
  @override
  double get minExtent => 40;
  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) => title != oldDelegate.title;
}

class _GridThumbnail extends StatelessWidget {
  final AssetEntity asset;
  const _GridThumbnail({required this.asset});

  @override
  Widget build(BuildContext context) {
    return AssetEntityImage(
      asset,
      isOriginal: false,
      thumbnailSize: const ThumbnailSize.square(200),
      thumbnailFormat: ThumbnailFormat.jpeg,
      fit: BoxFit.cover,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }
        // Simplified placeholder for better scrolling performance
        return Container(color: const Color(0xff121212));
      },
      errorBuilder: (context, error, stackTrace) => Container(
        color: const Color(0xff1A1A1A),
        child: const Center(
          child: Icon(Icons.broken_image_outlined, color: Colors.white12, size: 22)),
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
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}

class FullScreenImageViewer extends StatefulWidget {
  final List<AssetEntity> assets;
  final int initialIndex;
  const FullScreenImageViewer(
      {super.key, required this.assets, required this.initialIndex});
  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late final PageController _pageController;
  late int _currentIndex;
  bool _showAppBar = true;
  bool _isZooming = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() { _pageController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final asset = widget.assets[_currentIndex];
    final date = asset.createDateTime.toLocal();
    final formattedDate = DateFormat('dd MMM yyyy').format(date);
    final formatTimes = DateFormat('hh:mm a').format(date);
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _showAppBar ? AppBar(
        backgroundColor: Colors.black.withOpacity(0.45),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        title: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Text(formattedDate, style: const TextStyle(
            color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(formatTimes, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ]),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: Colors.black,
            onSelected: (value) {
              if (value == 'Details') _showPhotoDetails(widget.assets[_currentIndex]);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Details',
                child: Text('More Details', style: TextStyle(color: Colors.white))),
            ],
          ),
        ],
      ) : null,
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.assets.length,
        physics: _isZooming ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemBuilder: (context, index) => _ZoomablePage(
          asset: widget.assets[index],
          onTap: () => setState(() => _showAppBar = !_showAppBar),
          onZoomChanged: (zoomed) {
            if (_isZooming != zoomed) setState(() => _isZooming = zoomed);
          },
        ),
      ),
    );
  }

  void _showPhotoDetails(AssetEntity asset) async {
    final file = await asset.file;
    int fileSize = 0;
    String filePath = "Unavailable";
    if (file != null) { fileSize = await file.length(); filePath = file.path; }
    final date = asset.createDateTime.toLocal();
    final formattedDate = DateFormat('dd MMM yyyy').format(date);
    final formattedTime = DateFormat('hh:mm a').format(date);
    final fileName = asset.title ?? "Unknown";
    final sizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);
    showModalBottomSheet(
      context: context, backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Center(child: Text("Photo Details",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
          const SizedBox(height: 20),
          detailRow("Name:", fileName),
          detailRow("Date:", formattedDate),
          detailRow("Time:", formattedTime),
          detailRow("Dimension:", "${asset.width} × ${asset.height}"),
          detailRow("Size:", "$sizeMB MB"),
          detailRow("Source:", _getPhotoSource(filePath)),
          detailRow("Path:", filePath),
          const SizedBox(height: 10),
        ]),
      ),
    );
  }

  String _getPhotoSource(String path) {
    final p = path.toLowerCase();
    if (p.contains('whatsapp')) return '💬 WhatsApp';
    if (p.contains('telegram')) return '✈️ Telegram';
    if (p.contains('instagram')) return '📸 Instagram';
    if (p.contains('screenshot')) return '📷 Screenshot';
    if (p.contains('download')) return '🌐 Downloaded';
    if (p.contains('dcim/camera')) return '📹 Camera';
    if (p.contains('dcim')) return '📹 Camera Roll';
    if (p.contains('snapchat')) return '👻 Snapchat';
    return '📁 Other';
  }

  Widget detailRow(String title, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 90, child: Text(title, style: const TextStyle(color: Colors.white54))),
        Expanded(child: Text(value, style: const TextStyle(color: Colors.white))),
      ]),
    );
  }
}

class _ZoomablePage extends StatefulWidget {
  final AssetEntity asset;
  final VoidCallback onTap;
  final Function(bool) onZoomChanged;
  const _ZoomablePage({required this.asset, required this.onTap, required this.onZoomChanged});
  @override
  State<_ZoomablePage> createState() => _ZoomablePageState();
}

class _ZoomablePageState extends State<_ZoomablePage>
    with SingleTickerProviderStateMixin {
  Uint8List? _imageData;
  bool _loading = true;
  bool _error = false;
  final TransformationController _transformationController = TransformationController();
  late AnimationController _animController;
  Animation<Matrix4>? _zoomAnimation;
  Offset _doubleTapPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 200))
      ..addListener(() {
        if (_zoomAnimation != null) _transformationController.value = _zoomAnimation!.value;
      });
    _loadImage();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadImage() async {
    try {
      final data = await widget.asset
          .thumbnailDataWithSize(const ThumbnailSize(1080, 1920),
            format: ThumbnailFormat.jpeg, quality: 92)
          .timeout(const Duration(seconds: 20), onTimeout: () => null);
      if (mounted) setState(() {
        _imageData = data; _loading = false; _error = data == null || data.isEmpty;
      });
    } catch (_) {
      if (mounted) setState(() { _loading = false; _error = true; });
    }
  }

  bool get _isZoomed => _transformationController.value.getMaxScaleOnAxis() > 1.01;

  void _handleDoubleTap() {
    final Matrix4 targetMatrix;
    if (_isZoomed) {
      targetMatrix = Matrix4.identity();
    } else {
      const double scale = 3.0;
      final x = _doubleTapPosition.dx;
      final y = _doubleTapPosition.dy;
      targetMatrix = Matrix4.identity()
        ..translate(-x * (scale - 1.0), -y * (scale - 1.0))
        ..scale(scale);
    }
    _zoomAnimation = Matrix4Tween(
      begin: _transformationController.value, end: targetMatrix)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (_loading) return const Center(child: CircularProgressIndicator(color: Colors.orange));
    if (_error) return const Center(
      child: Icon(Icons.broken_image_outlined, color: Colors.white38, size: 60));
    return Listener(
      onPointerDown: (event) => _doubleTapPosition = event.localPosition,
      child: GestureDetector(
        onTap: widget.onTap,
        onDoubleTap: _handleDoubleTap,
        child: InteractiveViewer(
          transformationController: _transformationController,
          minScale: 1.0, maxScale: 5.0,
          clipBehavior: Clip.none, panEnabled: true,
          onInteractionUpdate: (details) {
            if (_transformationController.value.getMaxScaleOnAxis() > 1.1) {
              widget.onZoomChanged(true);
            } else {
              widget.onZoomChanged(false);
            }
          },
          onInteractionEnd: (details) {
            if (_transformationController.value.getMaxScaleOnAxis() <= 1.1) {
              widget.onZoomChanged(false);
              // Reset to identity if scale dropped too low
              if (_transformationController.value.getMaxScaleOnAxis() < 1.0) {
                 _transformationController.value = Matrix4.identity();
              }
            }
            setState(() {});
          },
          child: SizedBox(
            width: size.width, height: size.height,
            child: Image.memory(_imageData!,
              fit: BoxFit.contain, width: size.width, height: size.height,
              gaplessPlayback: true,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.broken_image_outlined, color: Colors.white38, size: 60))),
          ),
        ),
      ),
    );
  }
}
