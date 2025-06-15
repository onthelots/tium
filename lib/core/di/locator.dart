import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:tium/data/datasources/onboarding/onboarding_remote_datasource.dart';
import 'package:tium/data/models/user/user_model.dart';
import 'package:tium/data/repositories/onboarding/onboarding_repository_impl.dart';
import 'package:tium/domain/repositories/onboarding/onboarding_repository.dart';
import 'package:tium/domain/usecases/onboarding/onboarding_usecase.dart';
import 'package:tium/presentation/onboarding/bloc/onboarding_bloc/onboarding_bloc.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {

  /// Firebase Firestore
  locator.registerLazySingleton<FirebaseFirestore>(
          () => FirebaseFirestore.instance);

  /// Onboarding Remote

  // 1.datasource
  locator.registerLazySingleton<OnboardingRemoteDataSource>(
          () => OnboardingRemoteDataSourceImpl(locator<FirebaseFirestore>()));

  // 2. repository
  locator.registerLazySingleton<OnboardingRepository>(
        () => OnboardingRepositoryImpl(locator<OnboardingRemoteDataSource>()));

  // 3. usecase
  locator.registerLazySingleton<GetOnboardingQuestions>(
        () => GetOnboardingQuestions(locator<OnboardingRepository>()));

  // 4. bloc
  locator.registerFactory<OnboardingBloc>(
        () => OnboardingBloc(locator<GetOnboardingQuestions>()));


  ///  Hive 초기화 + 활용 시, 어댑터 등록
  await Hive.initFlutter(); // Hive 초기화
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(UserPlantAdapter());

  // <----- Lotto Local ----->
  /// Local 모델에 따른 Box 할당할 것
  // final box = await Hive.openBox<LottoLocalModel>('lottoBox'); // Hive Box 열기

  // locator.registerLazySingleton<LottoLocalDataSource>(
  //         () => LottoLocalDataSource(box));
  //
  // locator.registerLazySingleton<LottoLocalRepository>(
  //         () => LottoLocalRepository(dataSource: locator<LottoLocalDataSource>()));
  //
  // locator.registerLazySingleton<LottoLocalUseCase>(
  //         () => LottoLocalUseCase(repository: locator<LottoLocalRepository>()));

}
