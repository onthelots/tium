import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // For date formatting and current month
import 'package:tium/core/di/locator.dart';
import 'package:tium/data/models/plant/plant_category_model.dart';
import 'package:tium/data/models/plant/plant_detail_api_model.dart'; // New API model
import 'package:tium/presentation/home/screen/plant_section/plant_section_list_screen.dart';
import 'package:tium/presentation/plant/bloc/plant_detail_bloc/plant_detail_bloc.dart';
import 'package:tium/presentation/plant/bloc/plant_detail_bloc/plant_detail_event.dart';
import 'package:tium/presentation/plant/bloc/plant_detail_bloc/plant_detail_state.dart';
import 'package:tium/presentation/plant/screen/plant_register_modal.dart';
import 'package:tium/presentation/plant/utils/plant_detail_utils.dart';
import 'package:tium/presentation/plant/utils/plant_tag_utils.dart';

class PlantDetailScreen extends StatelessWidget {
  final String name; // 식물 이름 (상세보기에는 없음)
  final String plantId; // 코드
  final PlantCategory category;
  final String imageUrl; // 이미지

  const PlantDetailScreen({
    Key? key,
    required this.name,
    required this.plantId,
    required this.category,
    required this.imageUrl,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocProvider(
      create: (_) =>
      locator<PlantDetailBloc>()
        ..add(PlantDetailRequested(
          id: plantId,
        )),
      child: Scaffold(
        body: BlocBuilder<PlantDetailBloc, PlantDetailState>(
          builder: (context, state) {
            if (state is PlantDetailLoading || state is PlantDetailInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is PlantDetailError) {
              return Center(child: Text(state.message));
            }

            if (state is PlantDetailLoaded) {
              final PlantDetailApiModel plant = state.plant;

              // 특징 태그 생성
              final featureTags = PlantTagUtils.generateTags(plant);

              // 특별관리 정보
              final hasSpecialManageInfo = (plant.speclmanageInfo ?? '')
                  .isNotEmpty;

              print("주의정보 : ${plant.speclmanageInfo}");
              print("코드 : ${plantId}");

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 300,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: CachedNetworkImage(
                        imageUrl: imageUrl, // Use the passed imageUrl
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: Colors.grey[300]),
                        errorWidget: (context, url, error) =>
                        const Icon(
                            Icons.broken_image, size: 100, color: Colors.grey),
                      ),
                      titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                      title: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name ?? '이름 없음',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              shadows: const [
                                Shadow(
                                  blurRadius: 8,
                                  color: Colors.black54,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            plant.plntbneNm ?? '학명 없음',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.white70,
                              shadows: const [
                                Shadow(
                                  blurRadius: 8,
                                  color: Colors.black54,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 특징 태그
                          if (featureTags.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: featureTags.map((tag) {
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PlantSectionListScreen(
                                            title: tag.label,
                                            filter: tag.filter,
                                            limit: 200,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Chip(
                                      label: Text(tag.label),
                                      backgroundColor: theme.primaryColor.withOpacity(0.1),
                                      labelStyle: TextStyle(
                                        color: theme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      side: BorderSide(color: theme.primaryColor.withOpacity(0.3)),
                                    ),
                                  );
                                }).toList(),
                              )
                            ),

                          // 특별 관리 정보 (접기/펴기)
                          if (hasSpecialManageInfo)
                            Card(
                              margin: const EdgeInsets.only(bottom: 16.0),
                              elevation: 0.5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ExpansionTile(
                                title: Text(
                                  '키우기 Tip',
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      plant.speclmanageInfo ?? "",
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),


                          // 간단한 정보글
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: Text(
                              PlantUtils.generateBriefInfo(plant),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                  fontStyle: FontStyle.italic),
                            ),
                          ),

                          // 기본 정보 (2x2 그리드)
                          Text(
                            '기본 관리',
                            style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.3,
                            // Adjust as needed
                            children: [
                              _GridInfoCard(
                                title: '물주기',
                                value: PlantUtils.getCurrentSeasonWaterCycle(
                                    plant),
                                icon: Icons.water_drop,
                                onTap: () => _showInfoDialog(context, '물주기',
                                    PlantUtils.getCurrentSeasonWaterCycle(
                                        plant)),
                              ),
                              _GridInfoCard(
                                title: '광도',
                                value: PlantUtils.mapLightDemandNames(
                                    plant.lighttdemanddoCodeNm),
                                icon: Icons.wb_sunny,
                                onTap: () => _showInfoDialog(context, '광도',
                                    PlantUtils.mapLightDemandNames(
                                        plant.lighttdemanddoCodeNm)),
                              ),
                              _GridInfoCard(
                                title: '관리 수준',
                                value: PlantUtils.mapManageDemandLevel(
                                    plant.managedemanddoCodeNm),
                                icon: Icons.star_half,
                                onTap: () => _showInfoDialog(context, '관리 수준',
                                    PlantUtils.mapManageDemandLevel(
                                        plant.managedemanddoCodeNm)),
                              ),
                              _GridInfoCard(
                                title: '생육 온도',
                                value: plant.grwhTpCodeNm ?? '정보 없음',
                                icon: Icons.thermostat,
                                onTap: () => _showInfoDialog(context, '생육 온도',
                                    plant.grwhTpCodeNm ?? '정보 없음'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // 하단 추가 정보
                          Text(
                            '추가 정보',
                            style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          _InfoSection(
                            title: '원산지',
                            value: plant.orgplceInfo ?? '정보 없음',
                            icon: Icons.location_on,
                          ),
                          _InfoSection(
                            title: '과명',
                            value: plant.fmlCodeNm ?? '정보 없음',
                            icon: Icons.category,
                          ),
                          _InfoSection(
                            title: '생육 형태',
                            value: PlantUtils.mapGrowthStyleNames(
                                plant.grwhstleCodeNm) ?? '정보 없음',
                            icon: Icons.nature,
                          ),
                          _InfoSection(
                            title: '습도',
                            value: plant.hdCodeNm ?? '정보 없음',
                            icon: Icons.opacity,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: BlocBuilder<PlantDetailBloc, PlantDetailState>(
          builder: (context, state) {
            if (state is PlantDetailLoaded) {
              return Material(
                color: theme.primaryColor.withOpacity(0.2), // 연한 primary 컬러 배경
                borderRadius: BorderRadius.circular(30), // 캡슐 모양 둥글게
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {
                    _showRegisterModal(context, state.plant);
                  },
                  splashColor: theme.primaryColor.withOpacity(0.3),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: theme.primaryColor, size: 24),
                        SizedBox(width: 8),
                        Text(
                            '식물 등록',
                            style: theme.textTheme.labelMedium
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // 다이얼로그 표시 함수
  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('닫기'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // 식물 등록 모달
  void _showRegisterModal(BuildContext context, PlantDetailApiModel plant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final screenHeight = MediaQuery
            .of(context)
            .size
            .height;
        final modalHeight = screenHeight * 0.8; // 화면 높이의 60%

        return SizedBox(
          height: modalHeight,
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery
                .of(context)
                .viewInsets
                .bottom),
            child: PlantRegisterModal(plant: plant),
          ),
        );
      },
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoSection({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (value.isEmpty || value == '정보 없음') return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GridInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _GridInfoCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // 높이 최소화해서 overflow 방지
            children: [
              Icon(icon, color: theme.primaryColor, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}