import 'package:flutter/material.dart';
import 'package:tium/presentation/search/screen/search_delegate.dart';

class SearchBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);
    return Container(
      height: maxExtent,
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: GestureDetector(
        onTap: () {
          showSearch(
            context: context,
            delegate: PlantSearchDelegate([]),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: theme.dividerColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, size: 20),
              const SizedBox(width: 12),
              Text("함께 하고 싶은 식물 검색", style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 68;
  @override
  double get minExtent => 68;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}