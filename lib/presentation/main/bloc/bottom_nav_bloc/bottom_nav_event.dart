abstract class BottomNavEvent {}

class TabSelected extends BottomNavEvent {
  final int index;
  TabSelected(this.index);
}
