import 'package:tium/data/datasources/onboarding/onboarding_remote_datasource.dart';
import 'package:tium/domain/entities/onboarding/onboarding_question_entity.dart';
import 'package:tium/domain/repositories/onboarding/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingRemoteDataSource remoteDataSource;

  OnboardingRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<OnboardingQuestion>> getQuestions() {
    return remoteDataSource.getQuestions();
  }
}