import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:tium/core/dio/api_client.dart';
import 'package:tium/data/datasources/location/juso_search_remote_datasource.dart';
import 'package:tium/data/datasources/location/location_remote_datasource.dart';
import 'package:tium/data/datasources/onboarding/onboarding_remote_datasource.dart';
import 'package:tium/data/datasources/plant/dry_garden_remote_datasource.dart';
import 'package:tium/data/datasources/plant/garden_remote_datasource.dart';
import 'package:tium/data/datasources/weather/weather_remote_datasource.dart';
import 'package:tium/data/models/user/user_model.dart';
import 'package:tium/data/repositories/location/juso_search_repository_impl.dart';
import 'package:tium/data/repositories/location/location_repository_impl.dart';
import 'package:tium/data/repositories/onboarding/onboarding_repository_impl.dart';
import 'package:tium/data/repositories/plant/plant_repository_impl.dart';
import 'package:tium/data/repositories/weather/weather_repository_impl.dart';
import 'package:tium/domain/repositories/location/juso_search_repository.dart';
import 'package:tium/domain/repositories/location/location_repository.dart';
import 'package:tium/domain/repositories/onboarding/onboarding_repository.dart';
import 'package:tium/domain/repositories/plant/plant_repository.dart';
import 'package:tium/domain/repositories/weather/weather_repository.dart';
import 'package:tium/domain/usecases/location/juso_search_usecase.dart';
import 'package:tium/domain/usecases/location/location_usecase.dart';
import 'package:tium/domain/usecases/onboarding/onboarding_usecase.dart';
import 'package:tium/domain/usecases/plant/plants_usecase.dart';
import 'package:tium/domain/usecases/weather/weather_usecase.dart';
import 'package:tium/presentation/home/bloc/juso_search/juso_search_cubit.dart';
import 'package:tium/presentation/home/bloc/location/location_search_bloc.dart';
import 'package:tium/presentation/home/bloc/weather/weather_bloc.dart';
import 'package:tium/presentation/onboarding/bloc/onboarding_bloc/onboarding_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tium/presentation/search/bloc/plant_search_bloc/plant_search_bloc.dart';


// ──────────────────────────────────────────────────────────────
// Locator 세팅
final locator = GetIt.instance;

Future<void> setupLocator() async {
  _registerCore(); // 공통 의존성(Firebase 등)
  _registerOnboarding(); // 온보딩
  _registerLocation(); // 위치
  _registerWeather(); // 날씨
  _registerJusoSearch(); // 주소 검색
  registerPlants(); // 농사로 API
  await _initHive(); // Hive 초기화 & 어댑터
}

// ──────────────────────────────────────────────────────────────
// Core
void _registerCore() {
  locator.registerLazySingleton<FirebaseFirestore>(
        () => FirebaseFirestore.instance,
  );
}

// ──────────────────────────────────────────────────────────────
// Onboarding
void _registerOnboarding() {
  // 1. datasource
  locator.registerLazySingleton<OnboardingRemoteDataSource>(
        () => OnboardingRemoteDataSourceImpl(locator()),
  );

  // 2. repository
  locator.registerLazySingleton<OnboardingRepository>(
        () => OnboardingRepositoryImpl(locator()),
  );

  // 3. use-case
  locator.registerLazySingleton<GetOnboardingQuestions>(
        () => GetOnboardingQuestions(locator()),
  );

  // 4. bloc
  locator.registerFactory<OnboardingBloc>(
        () => OnboardingBloc(locator()),
  );
}

// ──────────────────────────────────────────────────────────────
// Gecoding (+Reverse Geocoding) Location
void _registerLocation() {
  // 1. ApiClient for Naver Map
  locator.registerLazySingleton<ApiClient>(
        () => ApiClient(
      baseUrl: 'https://maps.apigw.ntruss.com',
      defaultHeaders: const {
        'X-NCP-APIGW-API-KEY-ID': 'r0x64wm99g',
        'X-NCP-APIGW-API-KEY': 'zbPbYdwm8OFeXkHPRHXDvpgHS9Li3pK3CAXNGZco',
        'Accept': 'application/json',
      },
    ),
    instanceName: 'naverMapClient',
  );

  // 2. datasource
  locator.registerLazySingleton<LocationRemoteDataSource>(
        () => NaverLocationRemote(
      client: locator<ApiClient>(instanceName: 'naverMapClient'),
    ),
  );

  // 3. repository
  locator.registerLazySingleton<LocationRepository>(
        () => LocationRepositoryImpl(locator()),
  );

  // 4. use-cases
  locator
    ..registerLazySingleton<FindLocationByAddress>(
          () => FindLocationByAddress(locator()),
    )
    ..registerLazySingleton<FindLocationByLatLng>(
          () => FindLocationByLatLng(locator()),
    );

  // 5. bloc
  locator.registerFactory<LocationBloc>(
        () => LocationBloc(
      findByAddress: locator(),
      findByLatLng:  locator(),
    ),
  );
}

// ──────────────────────────────────────────────────────────────
// Search Location

void _registerJusoSearch() {
  // 1. ApiClient
  locator.registerLazySingleton<ApiClient>(
        () =>
        ApiClient(
          baseUrl: 'https://business.juso.go.kr/addrlink/addrLinkApi.do',
          defaultQuery: const {
            'confmKey': 'U01TX0FVVEgyMDI1MDYyMjE5MDI0ODExNTg2Njg=', // locator에서 주입
            'resultType': 'json',
          },
        ),
    instanceName: 'jusoClient',
  );

  // 2. DataSource
  locator.registerLazySingleton<JusoSearchRemoteDataSource>(
        () =>
        JusoSearchRemoteDataSourceImpl(
          locator<ApiClient>(instanceName: 'jusoClient'),
        ),
  );

  // 3. Repository
  locator.registerLazySingleton<JusoSearchRepository>(
        () => JusoSearchRepositoryImpl(locator()),
  );

  // 4. UseCase
  locator.registerLazySingleton<SearchAddressUseCase>(
        () => SearchAddressUseCase(locator()),
  );

  // 5. Cubit
  locator.registerFactory<JusoSearchCubit>(
        () => JusoSearchCubit(locator()),
  );
}

// ──────────────────────────────────────────────────────────────
// Weather
void _registerWeather() {
  // 1. ApiClients
  locator
    ..registerLazySingleton<ApiClient>(
          () => ApiClient(
        baseUrl: 'https://apis.data.go.kr/1360000/LivingWthrIdxServiceV4',
        defaultQuery: const {
          'ServiceKey': '7ff8qVQo7CpSswxVszAu/HHHAKjtELYDlATssGgNiwlBWHUuHnQW1/6Jxhv7S1f90YKLYqyG1DcsV7xXqIgoyw=='
        },
      ),
      instanceName: 'uvClient',
    )
    ..registerLazySingleton<ApiClient>(
          () => ApiClient(
        baseUrl: 'https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0',
        defaultQuery: const {
          'ServiceKey': '7ff8qVQo7CpSswxVszAu/HHHAKjtELYDlATssGgNiwlBWHUuHnQW1/6Jxhv7S1f90YKLYqyG1DcsV7xXqIgoyw=='
        },
      ),
      instanceName: 'tempClient',
    );

  // 2. datasource
  locator.registerLazySingleton<WeatherRemoteDataSource>(
        () => WeatherRemoteDataSourceImpl(
      uvClient:   locator<ApiClient>(instanceName: 'uvClient'),
      tempClient: locator<ApiClient>(instanceName: 'tempClient'),
    ),
  );

  // 3. repository
  locator.registerLazySingleton<WeatherRepository>(
        () => WeatherRepositoryImpl(locator()),
  );

  // 4. use-cases
  locator
    ..registerLazySingleton<GetUVIndex>(
          () => GetUVIndex(locator()),
    )
    ..registerLazySingleton<GetCurrentTemperature>(
          () => GetCurrentTemperature(locator()),
    );

  // 5. bloc
  locator.registerFactory<WeatherBloc>(
        () => WeatherBloc(
      locator<GetUVIndex>(),
      locator<GetCurrentTemperature>(),
    ),
  );
}

// ──────────────────────────────────────────────────────────────
// Plants (농사로 API)
void registerPlants() {
  // 1. ApiClients
  locator
    .registerLazySingleton<ApiClient>(
          () => ApiClient(
        baseUrl: 'http://api.nongsaro.go.kr/service',
        defaultQuery: const {
          'apiKey': '20250612VVRTBWINLAYYISM2ILTXCA',
          'format': 'json',
        },
      ),
      instanceName: 'nongsaroClient',
    );

  // 2. datasources
  locator.registerLazySingleton<DryGardenRemoteDataSource>(
        () => DryGardenRemoteDataSourceImpl(
      locator<ApiClient>(instanceName: 'nongsaroClient'),
    ),
  );
  locator.registerLazySingleton<GardenRemoteDataSource>(
        () => GardenRemoteDataSourceImpl(
      locator<ApiClient>(instanceName: 'nongsaroClient'),
    ),
  );

  // 3. repository
  locator.registerLazySingleton<PlantRepository>(
        () => PlantRepositoryImpl(
      dryGardenRemote: locator(),
      gardenRemote: locator(),
    ),
  );

  // 4. usecases
  locator
    ..registerLazySingleton<GetDryGardenPlants>(
            () => GetDryGardenPlants(locator()))
    ..registerLazySingleton<GetIndoorGardenPlants>(
            () => GetIndoorGardenPlants(locator()));

  // 5. bloc
  locator.registerFactory<SearchBloc>(
        () => SearchBloc(
      getDryGardenPlants: locator(),
      getIndoorGardenPlants: locator(),
    ),
  );
}


// ──────────────────────────────────────────────────────────────
// Hive
Future<void> _initHive() async {
  await Hive.initFlutter();
  Hive
    ..registerAdapter(UserModelAdapter())
    ..registerAdapter(UserPlantAdapter())
    ..registerAdapter(UserLocationAdapter());
}
