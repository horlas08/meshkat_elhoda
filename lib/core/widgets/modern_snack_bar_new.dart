import 'dart:async';
import 'package:flutter/material.dart';

class ModernSnackBar {
  static OverlayEntry? _currentEntry;

  // Private constructor to prevent instantiation
  ModernSnackBar._();

  static void show({
    required BuildContext context,
    required String message,
    required SnackBarType type,
    String? actionText,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    // Remove any existing snackbar first
    _removeCurrentSnackBar();

    final color = _getColor(type);
    final icon = _getIcon(type);
    final title = _getTitle(type);

    // Get the overlay state
    final overlay = Overlay.of(context, rootOverlay: true);
    if (!context.mounted) return;

    // Create a new overlay entry with a StatefulBuilder to manage local state
    _currentEntry = OverlayEntry(
      builder: (BuildContext context) => StatefulBuilder(
        builder: (context, setState) {
          return _SnackBarOverlay(
            message: message,
            color: color,
            icon: icon,
            title: title,
            actionText: actionText,
            onAction: () {
              onAction?.call();
              _removeCurrentSnackBar();
            },
            onClose: _removeCurrentSnackBar,
            duration: duration,
          );
        },
      ),
    );

    // Insert the overlay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_currentEntry != null && overlay.mounted) {
        overlay.insert(_currentEntry!);
      }
    });
  }

  static void hide() {
    _removeCurrentSnackBar();
  }

  static void _removeCurrentSnackBar() {
    _currentEntry?.remove();
    _currentEntry = null;
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
  Timer? _timer;
  bool _isClosing = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(widget.duration, _close);
  }

  Future<void> _close() async {
    if (_isClosing) return;
    _isClosing = true;

    if (mounted) {
      await _animationController.reverse();
      if (mounted) {
        widget.onClose();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, -1.0), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Curves.easeOut,
              ),
            ),
        child: Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(widget.icon, color: widget.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.message,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  if (widget.actionText != null)
                    TextButton(
                      onPressed: () {
                        widget.onAction?.call();
                        _close();
                      },
                      child: Text(widget.actionText!),
                    ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
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
