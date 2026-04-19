import 'package:Billy/pages/prove/segment/segment_control_prove_page.dart';
import 'package:Billy/pages/prove/segment/ui_provider_prove.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SegmentPageProve extends ConsumerStatefulWidget {
  const SegmentPageProve({super.key});

  @override
  ConsumerState<SegmentPageProve> createState() => _SegmentPageProveState();
}

class _SegmentPageProveState extends ConsumerState<SegmentPageProve> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    ref.read(tabProviderProve.notifier).state = index;

    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    ref.read(tabProviderProve.notifier).state = index;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(tabProviderProve);

    return Scaffold(
      appBar: AppBar(title: const Text("Transactions")),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // Segmented control
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedControlProve(
              selectedIndex: selectedIndex,
              onChanged: _onTabChanged,
            ),
          ),

          const SizedBox(height: 16),

          // PageView
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: _onPageChanged,
              children: const [
                Text("Entrate", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text("Uscite", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}