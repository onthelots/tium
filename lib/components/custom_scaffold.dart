import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final Widget? trailing;
  final Widget? bottom;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final bool appBarVisible;
  final bool centerTitle;
  final bool leadingVisible;  // 추가
  final double elevation;

  const CustomScaffold({
    Key? key,
    required this.body,
    this.title,
    this.titleWidget,
    this.leading,
    this.trailing,
    this.bottom,
    this.padding,
    this.backgroundColor,
    this.appBarVisible = true,
    this.centerTitle = true,
    this.leadingVisible = true,  // 기본값 true로 추가
    this.elevation = 1.0,
  })  : assert(title == null || titleWidget == null, 'title or titleWidget 둘 중 하나만 지정해야 합니다.'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 기본 뒤로가기 leading 버튼
    final defaultLeading = Navigator.of(context).canPop()
        ? IconButton(
      icon: const Icon(Icons.chevron_left),
      onPressed: () => Navigator.of(context).pop(),
    )
        : null;

    return Scaffold(
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      appBar: appBarVisible
          ? AppBar(
        backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
        elevation: elevation,
        shadowColor: Colors.transparent,
        centerTitle: centerTitle,
        leading: leadingVisible
            ? (leading ?? defaultLeading)
            : null,  // leadingVisible이 false면 null 처리
        title: titleWidget ?? (title != null ? Text(title!, style: theme.textTheme.titleMedium) : null),
        actions: trailing != null
            ? [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: trailing!,
          ),
        ]
            : null,
        bottom: bottom != null ? PreferredSize(preferredSize: const Size.fromHeight(20), child: bottom!) : null,
      )
          : null,
      body: SafeArea(
        child: Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: body,
        ),
      ),
    );
  }
}
