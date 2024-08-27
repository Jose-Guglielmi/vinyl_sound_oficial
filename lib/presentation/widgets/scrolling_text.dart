import 'package:flutter/material.dart';

class ScrollingText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const ScrollingText({
    super.key,
    required this.text,
    required this.style,
  });

  @override
  ScrollingTextState createState() => ScrollingTextState();
}

class ScrollingTextState extends State<ScrollingText>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  double _maxOffset = 0.0;
  final _longTextKey = GlobalKey();
  bool _hasOverflow = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateMaxOffset();
    });
  }

  void _calculateMaxOffset() {
    final RenderBox? renderBox =
        _longTextKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _maxOffset = renderBox.size.width - context.size!.width;
        _hasOverflow = _maxOffset > 0;
        if (_hasOverflow) {
          _animationController.repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth, // Usar el ancho disponible
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              if (_hasOverflow) {
                double offset = _animationController.value * _maxOffset;
                _scrollController.jumpTo(offset);
              }
              return SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: child,
              );
            },
            child: Text(
              widget.text,
              textAlign: TextAlign.center,
              key: _longTextKey,
              style: widget.style,
            ),
          ),
        );
      },
    );
  }
}
