import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tium/data/models/plant/plant_category_model.dart';
import 'package:tium/data/models/plant/plant_summary_api_model.dart';

class PlantLocalDataSource {
  final SupabaseClient supabaseClient;

  PlantLocalDataSource({required this.supabaseClient});

  Future<void> savePlants(List<PlantSummaryApiModel> plants) async {
    final List<Map<String, dynamic>> dataToInsert = plants.map((plant) => {
      'id': plant.id,
      'name': plant.name,
      'image_url': plant.imageUrl,
      'high_res_image_url': plant.highResImageUrl,
      'category': plant.category.toString().split('.').last, // Store enum as string
    }).toList();

    // Use upsert to insert new records or update existing ones based on 'id'
    await supabaseClient.from('plants_summary').upsert(dataToInsert, onConflict: 'id');
  }

  Future<List<PlantSummaryApiModel>> getPlants() async {
    final List<Map<String, dynamic>> response = await supabaseClient
        .from('plants_summary')
        .select('*')
        .order('name', ascending: true); // Order by name for consistency

    return response.map((json) {
      return PlantSummaryApiModel(
        id: json['id'] as String,
        name: json['name'] as String,
        imageUrl: json['image_url'] as String,
        highResImageUrl: json['high_res_image_url'] as String?,
        category: PlantCategory.values.firstWhere(
              (e) => e.toString().split('.').last == json['category'],
          orElse: () => PlantCategory.indoorGarden, // Default or handle unknown
        ),
      );
    }).toList();
  }
}