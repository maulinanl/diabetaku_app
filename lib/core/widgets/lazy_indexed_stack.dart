import 'package:flutter/material.dart';

class LazyIndexedStack extends StatelessWidget {
  final int index;
  final List<Widget> children;

  const LazyIndexedStack({
    super.key,
    required this.index,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: index,
      children: children,
    );
  }
}
