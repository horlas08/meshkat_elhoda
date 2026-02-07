import 'package:flutter/material.dart';

class ModernSnackBar {
  static OverlayEntry? _currentOverlay;

  static void show({
    required BuildContext context,
    required String message,
    required SnackBarType type,
    String? actionText,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    // Remove existing overlay if any
    _currentOverlay?.remove();
    _currentOverlay = null;

    final color = _getColor(type);
    final icon = _getIcon(type);
    final title = _getTitle(type);

    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => _SnackBarOverlay(
        message: message,
        color: color,
        icon: icon,
        title: title,
        actionText: actionText,
        onAction: onAction,
        onClose: () {
          _currentOverlay?.remove();
          _currentOverlay = null;
        },
        duration: duration,
      ),
    );

    _currentOverlay = overlayEntry;
    overlay.insert(overlayEntry);
  }

  static Color _getColor(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return const Color(0xFF10B981);
      case SnackBarType.error:
        return const Color(0xFFEF4444);
      case SnackBarType.warning:
        return const Color(0xFFF59E0B);
      case SnackBarType.info:
        return const Color(0xFF3B82F6);
    }
  }

  static IconData _getIcon(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Icons.check_circle_rounded;
      case SnackBarType.error:
        return Icons.error_rounded;
      case SnackBarType.warning:
        return Icons.warning_rounded;
      case SnackBarType.info:
        return Icons.info_rounded;
    }
  }

  static String _getTitle(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return 'تم بنجاح';
      case SnackBarType.error:
        return 'خطأ';
      case SnackBarType.warning:
        return 'تحذير';
      case SnackBarType.info:
        return 'معلومة';
    }
  }
}

enum SnackBarType { success, error, warning, info }

class _SnackBarOverlay extends StatefulWidget {
  final String message;
  final Color color;
  final IconData icon;
  final String title;
  final String? actionText;
  final VoidCallback? onAction;
  final VoidCallback onClose;
  final Duration duration;

  const _SnackBarOverlay({
    required this.message,
    required this.color,
    required this.icon,
    required this.title,
    this.actionText,
    this.onAction,
    required this.onClose,
    required this.duration,
  });

  @override
  _SnackBarOverlayState createState() => _SnackBarOverlayState();
}

class _SnackBarOverlayState extends State<_SnackBarOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _positionAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    // إغلاق تلقائي
    Future.delayed(widget.duration, () {
      if (mounted) _close();
    });
  }

  void _close() {
    _controller.reverse().then((_) {
      if (mounted) widget.onClose();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      left: 20,
      right: 20,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: SlideTransition(
          position: _positionAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: widget.color.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(widget.icon, color: widget.color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            color: widget.color,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.message,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (widget.actionText != null) ...[
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        widget.onAction?.call();
                        _close();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: widget.color,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        widget.actionText!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey, size: 18),
                    onPressed: _close,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
