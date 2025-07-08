import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/data/models/user/user_model.dart';
import 'package:tium/data/models/user/user_type_model.dart';
import 'package:tium/domain/usecases/onboarding/get_user_type_model_from_enum_usecase.dart';

part 'user_type_state.dart';

class UserTypeCubit extends Cubit<UserTypeState> {
  final GetUserTypeModelFromEnumUseCase getUserTypeModelFromEnumUseCase;

  UserTypeCubit({required this.getUserTypeModelFromEnumUseCase}) : super(UserTypeInitial());

  Future<void> loadUserTypeModel(UserType userType) async {
    emit(UserTypeLoading());
    print('- Cubit - 유저타입 불러오기 시작');
    try {
      print('- Cubit - 유저타입 불러오는 중.. UseCase 실행');
      final userTypeModel = await getUserTypeModelFromEnumUseCase(userType);
      print('- Cubit - 유저타입 불러오기 성공');
      emit(UserTypeLoaded(userTypeModel));
    } catch (e) {
      print('- Cubit - 유저타입 불러오기 실패: $e');
      emit(UserTypeError(e.toString()));
    }
  }
}
