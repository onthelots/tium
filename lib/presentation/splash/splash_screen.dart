import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/components/custom_loading_indicator.dart';
import 'package:tium/core/constants/app_asset.dart';
import 'package:tium/core/routes/routes.dart';
import 'package:tium/core/services/shared_preferences_helper.dart';
import 'package:tium/presentation/plant/bloc/plant_data/plant_data_bloc.dart';

class SplashScreen extends StatelessWidget {
  final String? initialPayload;
  const SplashScreen({super.key, this.initialPayload});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlantDataBloc, PlantDataState>(
      listener: (context, state) async { // Make listener async
        if (state is PlantDataLoaded) {
          final isFirstRun = await SharedPreferencesHelper.getFirstRun();
          String nextRoute;

          if (initialPayload != null) {
            nextRoute = Routes.main; // If launched from notification, go to main
          } else if (isFirstRun) {
            nextRoute = Routes.intro; // If first run, go to intro
          } else {
            nextRoute = Routes.main; // Otherwise, go to main
          }
          Navigator.of(context).pushReplacementNamed(nextRoute);
        } else if (state is PlantDataError) {
          // Handle error, maybe show an error message and retry option
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load plant data: ${state.message}')),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.green[50], // A light green background for a fresh feel
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              const CustomLoadingIndicator(), // Green indicator
              const SizedBox(height: 30),
              Text(
                '식물 정보를 불러오는 중이에요...\n잠시만 기다려 주세요!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800], // Darker green text
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '더욱 풍성한 식물 생활을 위해 준비하고 있어요!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}