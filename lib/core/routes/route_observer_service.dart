import 'package:flutter/material.dart';

class RouteObserverService extends NavigatorObserver {
  static final RouteObserverService _instance = RouteObserverService._internal();
  factory RouteObserverService() => _instance;
  RouteObserverService._internal();

  Route<dynamic>? _currentRoute;
  String? _currentRouteName;

  Route<dynamic>? get currentRoute => _currentRoute;
  String? get currentRouteName => _currentRouteName;

  @override
  void didPush(Route route, Route? previousRoute) {
    _currentRoute = route;
    _currentRouteName = route.settings.name;
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _currentRoute = previousRoute;
    _currentRouteName = previousRoute?.settings.name;
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    _currentRoute = newRoute;
    _currentRouteName = newRoute?.settings.name;
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}
