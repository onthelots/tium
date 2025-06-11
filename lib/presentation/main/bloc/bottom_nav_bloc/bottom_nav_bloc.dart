import 'package:flutter_bloc/flutter_bloc.dart';
import 'bottom_nav_event.dart';
import 'bottom_nav_state.dart';

class BottomNavBloc extends Bloc<TabSelected, TabState> {
  BottomNavBloc() : super(TabState(0)) {
    on<TabSelected>((event, emit) {
      emit(TabState(event.index));
    });
  }
}
