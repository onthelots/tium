abstract class BottomNavState {}

class TabState extends BottomNavState {
  final int index;
  TabState(this.index);
}
