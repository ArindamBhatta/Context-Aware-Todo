// ignore: file_names
import 'package:flutter/material.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';

class ScrollableTabBar extends StatefulWidget {
  final List<String> menuOptions;
  final Function? onTap;
  final TabController? tabController;
  final int selectedIndex;
  final double tabHeight;
  final double tabHPadding;
  final double labelVPadding;
  final double adjustmentHeight;
  final double labelHPadding;
  final Color indicatorColor;
  final Color unselectedLabelColor;
  final Color labelColor;
  const ScrollableTabBar({
    super.key,
    required this.menuOptions,
    this.onTap,
    this.selectedIndex = 0,
    this.tabController,
    this.tabHeight = 25,
    this.tabHPadding = 5,
    this.labelVPadding = 5,
    this.adjustmentHeight = 1,
    this.indicatorColor = const Color(0xFF4F46E5), // Indigo 600
    this.unselectedLabelColor = const Color(0xFF64748B), // Slate 500
    this.labelColor = Colors.white,
    this.labelHPadding = 13,
  });

  @override
  State<ScrollableTabBar> createState() => _ScrollableTabBarState();
}

class _ScrollableTabBarState extends State<ScrollableTabBar> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: widget.selectedIndex,
      length: widget.menuOptions.length,
      child: Align(
        alignment: Alignment.centerLeft,
        child: TabBar(
          controller: widget.tabController,
          onTap: (int index) {
            if (widget.onTap == null) return;
            widget.onTap!(index);
          },
          isScrollable: true,
          physics: const BouncingScrollPhysics(),
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorColor: widget.indicatorColor,
          //* padding for the indicator
          indicatorPadding: EdgeInsets.only(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
          ),
          indicatorWeight: 0,
          indicator: RectangularIndicator(
            verticalPadding: 0,
            color: widget.indicatorColor,
            bottomLeftRadius: 8,
            bottomRightRadius: 8,
            topLeftRadius: 8,
            topRightRadius: 8,
          ),
          unselectedLabelColor: widget.unselectedLabelColor,
          labelColor: widget.labelColor,
          labelStyle: Theme.of(context).textTheme.headlineSmall,
          labelPadding: EdgeInsets.zero,
          tabs: [
            for (var items in widget.menuOptions)
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ), // optional
                child: Tab(
                  iconMargin: EdgeInsets.zero,
                  height: widget.tabHeight,
                  child: SizedBox(
                    width: 180,
                    child: Text(
                      items,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
