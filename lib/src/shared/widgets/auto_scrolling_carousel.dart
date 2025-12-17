import 'package:flutter/material.dart';

/// A widget that auto-scrolls its children horizontally from right to left
/// like a marquee. Stops when user interacts and resumes after.
class AutoScrollingCarousel extends StatefulWidget {
  final List<Widget> children;
  final double height;
  final double spacing;
  final Duration scrollDuration;
  final Duration pauseDuration;

  const AutoScrollingCarousel({
    super.key,
    required this.children,
    required this.height,
    this.spacing = 12.0,
    this.scrollDuration = const Duration(seconds: 30),
    this.pauseDuration = const Duration(seconds: 2),
  });

  @override
  State<AutoScrollingCarousel> createState() => _AutoScrollingCarouselState();
}

class _AutoScrollingCarouselState extends State<AutoScrollingCarousel> {
  late ScrollController _scrollController;
  bool _isUserInteracting = false;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoScroll() async {
    if (!mounted) return;
    if (_isUserInteracting) return;
    if (_scrollController.positions.isEmpty) return;

    _isScrolling = true;

    // Wait a bit before starting
    await Future.delayed(widget.pauseDuration);
    if (!mounted || _isUserInteracting) {
      _isScrolling = false;
      return;
    }

    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) {
      _isScrolling = false;
      return;
    }

    // Scroll to the end
    await _scrollController.animateTo(
      maxScroll,
      duration: widget.scrollDuration,
      curve: Curves.linear,
    );

    if (!mounted || _isUserInteracting) {
      _isScrolling = false;
      return;
    }

    // Wait at the end
    await Future.delayed(widget.pauseDuration);
    if (!mounted || _isUserInteracting) {
      _isScrolling = false;
      return;
    }

    // Scroll back to start
    await _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );

    _isScrolling = false;

    if (mounted && !_isUserInteracting) {
      _startAutoScroll();
    }
  }

  void _onUserInteractionStart() {
    _isUserInteracting = true;
  }

  void _onUserInteractionEnd() {
    _isUserInteracting = false;
    if (!_isScrolling) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && !_isUserInteracting && !_isScrolling) {
          _startAutoScroll();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollStartNotification) {
            if (notification.dragDetails != null) {
              _onUserInteractionStart();
            }
          } else if (notification is ScrollEndNotification) {
            _onUserInteractionEnd();
          }
          return false;
        },
        child: ListView.separated(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: widget.children.length,
          separatorBuilder: (context, index) => SizedBox(width: widget.spacing),
          itemBuilder: (context, index) => widget.children[index],
        ),
      ),
    );
  }
}
