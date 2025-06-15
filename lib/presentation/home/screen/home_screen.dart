import 'package:flutter/material.dart';
import 'package:tium/core/services/hive/hive_prefs.dart';
import 'package:tium/core/services/hive/onboarding/onboarding_prefs.dart';
import 'package:tium/data/models/user/user_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await UserPrefs.getUser();
    setState(() => _user = user);
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('홈')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🌱 키우는 환경: ${_user!.environment}'),
            const SizedBox(height: 10),
            Text('🌾 관심 작물: ${_user!.interests.join(", ")}'),
            const SizedBox(height: 10),
            Text('🌿 경험 수준: ${_user!.experience}'),
            const SizedBox(height: 10),
            Text('실내 식물 수: ${_user!.indoorPlants.length}개'),
            Text('실외 식물 수: ${_user!.outdoorPlants.length}개'),
          ],
        ),
      ),
    );
  }
}
