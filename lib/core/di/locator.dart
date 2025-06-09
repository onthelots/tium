import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {

  /// Firebase Firestore
  locator.registerLazySingleton<FirebaseFirestore>(
          () => FirebaseFirestore.instance);


  ///  Hive 초기화 + 활용 시, 어댑터 등록
  await Hive.initFlutter(); // Hive 초기화
  // Hive.registerAdapter(LottoLocalModelAdapter()); // LottoLocalModel 어댑터 등록
  // Hive.registerAdapter(LottoEntryAdapter()); // LottoEntry 어댑터 등록

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
