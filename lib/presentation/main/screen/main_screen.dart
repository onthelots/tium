import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/presentation/home/screen/home_screen.dart';
import 'package:tium/presentation/management/screen/management_screen.dart';
import 'package:tium/presentation/mypage/screen/mypage_screen.dart';
import 'package:tium/presentation/search/bloc/plant_search_bloc/plant_search_bloc.dart';
import 'package:tium/presentation/search/bloc/plant_search_bloc/plant_search_event.dart';
import '../../../core/constants/constants.dart';
import '../bloc/bottom_nav_bloc/bottom_nav_bloc.dart';
import '../bloc/bottom_nav_bloc/bottom_nav_event.dart';
import '../bloc/bottom_nav_bloc/bottom_nav_state.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  @override
  void initState() {
    super.initState();
    context.read<SearchBloc>().add(SearchLoadedRequested());
  }

  final List<Widget> _tabs = [
    HomeScreen(),
    ManagementScreen(),
    // SearchScreen(),
    MyPageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BottomNavBloc(),
      child: BlocBuilder<BottomNavBloc, TabState>(
        builder: (context, state) {
          final currentIndex = state.index; // 기본값 0
          return Scaffold(
            body: IndexedStack(
              index: currentIndex,
              children: _tabs,
            ),
            bottomNavigationBar: Platform.isIOS
                ? CupertinoTabBar(
              currentIndex: currentIndex,
              items: CustomBottomNavigationBar.bottomNavigationBarItem,
              onTap: (index) {
                context.read<BottomNavBloc>().add(TabSelected(index)); // 이벤트 전달
              },
              activeColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
              inactiveColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor ?? Colors.white10,
              backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
            )
                : BottomNavigationBar(
              currentIndex: currentIndex,
              items: CustomBottomNavigationBar.bottomNavigationBarItem,
              onTap: (index) {
                context.read<BottomNavBloc>().add(TabSelected(index)); // 이벤트 전달
              },
              selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
              unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
              backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
            ),
          );
        },
      ),
    );
  }
}
