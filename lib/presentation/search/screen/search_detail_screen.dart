import 'package:flutter/material.dart';
import 'package:tium/core/di/locator.dart';
import 'package:tium/data/models/plant/plant_model.dart';
import 'package:tium/domain/usecases/plant/plants_usecase.dart';

class PlantDetailScreen extends StatelessWidget {
  const PlantDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String id = args['id'];
    final PlantCategory category = args['category'];

    return Scaffold(
      body: FutureBuilder<PlantDetail>(
        future: locator<GetPlantDetail>().call(id, category),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('데이터를 불러오지 못했습니다.'));
          }

          final plant = snapshot.data!;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 280,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(plant.name),
                  background: Hero(
                    tag: plant.id,
                    child: Image.network(
                      plant.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('설명', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(plant.description.isNotEmpty ? plant.description : '설명 데이터가 없습니다.'),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}