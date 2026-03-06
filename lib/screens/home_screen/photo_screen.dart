import 'package:flutter/material.dart';
import 'package:chronogram/modal/user_detail_modal.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:chronogram/screens/home_screen/home_screen.dart';

class PhotoScreen extends StatefulWidget {
  final UserDetailModal? user;
  final String? userName;

  const PhotoScreen({super.key, this.user, this.userName});

  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  final Map<String, List<AssetEntity>> _groupedMedia = {};
  bool _isLoading = true;
  int _page = 0;
  final int _size = 30; // Reduced for older device memory optimization
  bool _hasMore = true;
  bool _isFetchingMore = false;
  AssetPathEntity? _currentAlbum;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchMedia();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isFetchingMore && _hasMore) {
        _fetchMoreMedia();
      }
    }
  }

  Future<void> _fetchMedia() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        onlyAll: true,
        type: RequestType.image,
      );
      if (albums.isNotEmpty) {
        _currentAlbum = albums[0];
        List<AssetEntity> media = await _currentAlbum!.getAssetListPaged(page: _page, size: _size);
        _groupMediaByDate(media, clear: true);
        _hasMore = media.length == _size;
      } else {
        setState(() => _isLoading = false);
      }
    } else {
      PhotoManager.openSetting();
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchMoreMedia() async {
    if (_currentAlbum == null) return;
    _isFetchingMore = true;
    _page++;
    
    List<AssetEntity> media = await _currentAlbum!.getAssetListPaged(page: _page, size: _size);
    if (media.isEmpty) {
      _hasMore = false;
    } else {
      _groupMediaByDate(media, clear: false);
      _hasMore = media.length == _size;
    }
    _isFetchingMore = false;
  }

  void _groupMediaByDate(List<AssetEntity> media, {required bool clear}) {
    if (clear) _groupedMedia.clear();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final lastWeek = today.subtract(const Duration(days: 7));
    final lastMonth = today.subtract(const Duration(days: 30));

    for (var asset in media) {
      final date = asset.createDateTime;
      final assetDate = DateTime(date.year, date.month, date.day);

      String group;
      if (assetDate == today) {
        group = "TODAY";
      } else if (assetDate == yesterday) {
        group = "YESTERDAY";
      } else if (assetDate.isAfter(lastWeek)) {
        group = "LAST WEEK";
      } else if (assetDate.isAfter(lastMonth)) {
        group = "LAST MONTH";
      } else {
        group = "EARLIER";
      }

      if (!_groupedMedia.containsKey(group)) {
        _groupedMedia[group] = [];
      }
      _groupedMedia[group]!.add(asset);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showFullScreenImage(AssetEntity asset) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(asset: asset),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Divider(color: Colors.white12, height: 1),
            _buildSubHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                  : _groupedMedia.isEmpty
                      ? const Center(
                          child: Text(
                            "No Media Found",
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                      : CustomScrollView(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          slivers: [
                            ..._groupedMedia.entries.map((entry) {
                              return SliverMainAxisGroup(
                                slivers: [
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 15, top: 20, bottom: 10),
                                      child: Text(
                                        entry.key,
                                        style: const TextStyle(
                                          color: Colors.orange,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SliverPadding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    sliver: SliverGrid(
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 6,
                                        mainAxisSpacing: 6,
                                      ),
                                      delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                          final asset = entry.value[index];
                                          return _SmoothClick(
                                            onTap: () => _showFullScreenImage(asset),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: AssetEntityImage(
                                                asset,
                                                isOriginal: false,
                                                thumbnailSize: const ThumbnailSize.square(120),
                                                thumbnailFormat: ThumbnailFormat.jpeg,
                                                fit: BoxFit.cover,
                                                loadingBuilder: (context, child, frame) {
                                                  if (frame == null) {
                                                    return Container(color: Colors.grey.shade900);
                                                  }
                                                  return child;
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                        childCount: entry.value.length,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                            if (_isFetchingMore)
                              const SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Center(child: CircularProgressIndicator(color: Colors.orange)),
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

  Widget _buildHeader() {
    String name = widget.userName ?? "User";
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
               shape: BoxShape.circle,
               border: Border.all(color: Colors.orange, width: 1.5),
               boxShadow: [
                  BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 10),
               ],
            ),
            child: Center(
               child: Text(
                  _getInitials(name),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
               ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                 name,
                 style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
               ),
               const Text(
                 "My Gallery",
                 style: TextStyle(color: Colors.white60, fontSize: 12),
               )
            ],
          ),
          const Spacer(),
          Container(
             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
             decoration: BoxDecoration(
                color: const Color(0xff3B260D),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.withOpacity(0.5)),
             ),
             child: Row(
                children: [
                   Container(
                      width: 6, height: 6,
                      decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                   ),
                   const SizedBox(width: 6),
                   const Text("Synced", style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
             ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.sync, color: Colors.white54, size: 22),
        ],
      ),
    );
  }

  Widget _buildSubHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Row(
        children: const [
           Icon(Icons.folder_open_outlined, color: Colors.orange, size: 20),
           SizedBox(width: 10),
           Text(
             "Select Folder for Sync",
             style: TextStyle(color: Colors.orange, fontSize: 14, fontWeight: FontWeight.bold),
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

class FullScreenImageViewer extends StatelessWidget {
  final AssetEntity asset;
  const FullScreenImageViewer({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () async {
              final file = await asset.file;
              if (file != null) {
                await Share.shareXFiles([XFile(file.path)]);
              }
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: AssetEntityImage(
            asset,
            isOriginal: true,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, frame) {
              if (frame == null) {
                return const Center(child: CircularProgressIndicator(color: Colors.orange));
              }
              return child;
            },
          ),
        ),
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
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}
