import 'package:flutter/material.dart';

class DotsIndicator extends StatelessWidget {
  final int dotsCount;
  final int position;
  final Color activeColor;
  final Color inactiveColor;

  const DotsIndicator({
    super.key,
    required this.dotsCount,
    required this.position,
    this.activeColor = Colors.white,
    this.inactiveColor = const Color(0x80FFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(dotsCount, (int index) {
        final bool isActive = index == position;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: isActive ? 12.0 : 8.0,
          height: isActive ? 12.0 : 8.0,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}


