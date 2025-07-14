import 'package:tium/data/models/plant/plant_summary_api_model.dart';

class PlantSection {
  final String title;
  final List<PlantSummaryApiModel> plants;
  final Map<String, String>? filter; // 👉 '더보기' 등에서 사용할 필터

  PlantSection(this.title, this.plants, {this.filter});
}
