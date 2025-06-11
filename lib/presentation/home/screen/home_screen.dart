import 'package:flutter/material.dart';
import 'package:tium/presentation/onboarding/screen/onboarding_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<Map<String, dynamic>> _loadPrefs() => OnboardingPrefs.loadOnboardingData();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadPrefs(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final data = snapshot.data!;
        return Scaffold(
          appBar: AppBar(title: const Text('홈')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🌱 키우는 환경: ${data['environment']}'),
                const SizedBox(height: 10),
                Text('🌾 관심 작물: ${(data['interests'] as List).join(', ')}'),
                const SizedBox(height: 10),
                Text('🌿 경험 수준: ${data['experience']}'),
              ],
            ),
          ),
        );
      },
    );
  }
}
