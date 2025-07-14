import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:tium/components/custom_loading_indicator.dart';
import 'package:tium/core/di/locator.dart';
import 'package:tium/core/routes/routes.dart';
import 'package:tium/data/models/plant/plant_summary_api_model.dart';
import 'package:tium/presentation/search/bloc/plant_search_bloc/plant_search_bloc.dart';
import 'package:tium/presentation/search/bloc/plant_search_bloc/plant_search_event.dart';
import 'package:tium/presentation/search/bloc/plant_search_bloc/plant_search_state.dart';
import 'package:tium/presentation/search/screen/search_delegate.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          onSubmitted: (value) {
            closeKeyboard();
            showSearch(
              context: context,
              delegate: PlantSearchDelegateWithQuery(initialQuery: value),
            );
          },
          // ...
        ),

        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 20),
          Text('Your history', style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }

  void closeKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}

class PlantSearchDelegateWithQuery extends PlantSearchDelegate {
  PlantSearchDelegateWithQuery({required String initialQuery}) {
    query = initialQuery;
  }
}
