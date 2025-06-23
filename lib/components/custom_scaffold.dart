import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  final Widget body;

  final String? title;
  final Widget? titleWidget;

  final Widget? leading;
  final bool leadingVisible;
  final String? leadingTitle;
  final double? leadingWidth;

  final Widget? trailing;
  final Widget? bottom;

  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final bool appBarVisible;
  final bool centerTitle;
  final double elevation;

  const CustomScaffold({
    Key? key,
    required this.body,
    this.title,
    this.titleWidget,
    this.leading,
    this.leadingVisible = true,
    this.leadingTitle,
    this.leadingWidth,
    this.trailing,
    this.bottom,
    this.padding,
    this.backgroundColor,
    this.appBarVisible = true,
    this.centerTitle = true,
    this.elevation = 1.0,
  })  : assert(title == null || titleWidget == null,
  'title 또는 titleWidget 둘 중 하나만 지정해야 합니다.'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget? buildLeadingTitle() {
      if (!leadingVisible) return null;

      if (leading != null) return leading;

      if (leadingTitle != null) {
        return Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            leadingTitle!,
            style: theme.textTheme.titleMedium,
          ),
        );
      }

      return null;
    }

    return Scaffold(
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      appBar: appBarVisible
          ? AppBar(
        backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
        elevation: elevation,
        shadowColor: Colors.transparent,
        centerTitle: centerTitle,
        leading: buildLeadingTitle(),
        leadingWidth: leadingTitle != null ? 120 : null,
        title: titleWidget ??
            (title != null
                ? Text(title!, style: theme.textTheme.titleMedium)
                : null),
        actions: trailing != null
            ? [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: trailing!,
          ),
        ]
            : null,
        bottom: bottom != null
            ? PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: bottom!,
        )
            : null,
      )
          : null,
      body: SafeArea(
        child: Padding(
          padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: body,
        ),
      ),
    );
  }
}
