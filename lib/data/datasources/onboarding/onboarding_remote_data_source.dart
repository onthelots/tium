import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tium/data/models/onboarding/onboarding_question_model.dart';
import 'package:tium/data/models/user/user_type_model.dart';

abstract class OnboardingRemoteDataSource {
  Future<List<OnboardingQuestionModel>> getOnboardingQuestions();
  Future<UserTypeModel> determineUserType(List<int> answerIds);
  Future<UserTypeModel> getUserTypeModelById(int id);
}

class OnboardingRemoteDataSourceImpl implements OnboardingRemoteDataSource {
  final SupabaseClient supabaseClient;

  OnboardingRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<OnboardingQuestionModel>> getOnboardingQuestions() async {
    try {
      final response = await supabaseClient
          .from('onboarding_questions')
          .select('*, onboarding_answers(*)')
          .order('question_order', ascending: true);

      final questions = (response as List)
          .map((question) => OnboardingQuestionModel.fromJson(question))
          .toList();
      return questions;
    } catch (e) {
      // 에러 처리
      print('Error fetching onboarding questions: $e');
      rethrow;
    }
  }

  @override
  Future<UserTypeModel> determineUserType(List<int> answerIds) async {
    try {
      final response = await supabaseClient.functions.invoke(
        'determine-user-type',
        body: {'answer_ids': answerIds},
      );

      if (response.status != 200) {
        throw 'Failed to determine user type: ${response.data}';
      }

      return UserTypeModel.fromJson(response.data);
    } catch (e) {
      print('Error invoking edge function: $e');
      rethrow;
    }
  }

  @override
  Future<UserTypeModel> getUserTypeModelById(int id) async {
    try {
      print('Supabase: Fetching user type model for ID: $id');
      final response = await supabaseClient
          .from('user_types')
          .select('*')
          .eq('id', id)
          .single();
      print('Supabase: Received response for ID $id: $response');
      return UserTypeModel.fromJson(response);
    } catch (e) {
      print('Supabase Error fetching user type model by ID $id: $e');
      rethrow;
    }
  }
}