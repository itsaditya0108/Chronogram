import 'package:flutter/material.dart';
import 'package:chronogram/app_helper/token_saver_helper/token_saver_helper.dart';

class TokenImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const TokenImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<TokenImage> createState() => _TokenImageState();
}

class _TokenImageState extends State<TokenImage> {
  String? _token;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  @override
  void didUpdateWidget(TokenImage oldWidget) {
    if (oldWidget.imageUrl != widget.imageUrl) {
      _loadToken();
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _loadToken() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final token = await TokenHelper.getToken();
    if (mounted) {
      setState(() {
        _token = token;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.placeholder ?? Container(color: Colors.black12);
    }

    if (_token == null || _token!.isEmpty) {
      return widget.errorWidget ?? const Icon(Icons.error);
    }

    return Image.network(
      widget.imageUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      headers: {
        "Authorization": "Bearer $_token",
      },
      errorBuilder: (context, error, stackTrace) {
        return widget.errorWidget ?? const Icon(Icons.broken_image);
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return widget.placeholder ?? Container(color: Colors.black12);
      },
    );
  }
}
