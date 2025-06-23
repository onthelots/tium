import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tium/data/models/onboarding/onboarding_question_model.dart';

// abstract class
abstract class OnboardingRemoteDataSource {
  Future<List<OnboardingQuestionModel>> getQuestions();
}

// 온보딩 데이터소스
class OnboardingRemoteDataSourceImpl implements OnboardingRemoteDataSource {
  final FirebaseFirestore firestore;

  OnboardingRemoteDataSourceImpl(this.firestore);

  @override
  Future<List<OnboardingQuestionModel>> getQuestions() async {
    final snapshot = await firestore
        .collection('onboarding_questions')
        .orderBy('order')
        .get();

    return snapshot.docs
        .map((doc) => OnboardingQuestionModel.fromFirestore(doc.data()))
        .toList();
  }
}
