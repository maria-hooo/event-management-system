import 'package:flutter/material.dart';

class BusyOverlay extends StatelessWidget {
  final bool busy;
  final Widget child;

  const BusyOverlay({super.key, required this.busy, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (busy)
          Positioned.fill(
            child: Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}
