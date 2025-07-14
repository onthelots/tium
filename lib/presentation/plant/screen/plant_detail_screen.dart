import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/components/custom_toast_message.dart';
import 'package:tium/core/di/locator.dart';
import 'package:tium/core/services/hive/onboarding/onboarding_prefs.dart';
import 'package:tium/data/models/plant/plant_category_model.dart';
import 'package:tium/data/models/plant/plant_detail_api_model.dart'; // New API model
import 'package:tium/presentation/plant/bloc/plant_detail_bloc/plant_detail_bloc.dart';
import 'package:tium/presentation/plant/bloc/plant_detail_bloc/plant_detail_event.dart';
import 'package:tium/presentation/plant/bloc/plant_detail_bloc/plant_detail_state.dart';
import 'package:tium/presentation/plant/screen/plant_register_modal.dart';
import 'package:tium/presentation/plant/utils/plant_detail_utils.dart';
import 'package:tium/presentation/plant/utils/plant_tag_utils.dart';
import 'package:tium/presentation/plant/widgets/plant_detail_info_section.dart';
import 'package:tium/presentation/plant/widgets/plant_grid_info_card.dart';

class PlantDetailScreen extends StatelessWidget {
  final String name; // 식물 이름 (상세보기에는 없음)
  final String id; // 코드
  final PlantCategory category;
  final String imageUrl; // 이미지

  const PlantDetailScreen({
    Key? key,
    required this.name,
    required this.id,
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
          id: id,
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

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 300,
                    pinned: true,
                    automaticallyImplyLeading: false, // 백버튼 제거
                    stretchTriggerOffset: 100,
                    backgroundColor: theme.primaryColor,
                    leading: null, // 기본 자동 생기지 않음
                    actions: [
                      Container(
                        margin: const EdgeInsets.only(right: 15,),
                        decoration: BoxDecoration(
                          color: theme.disabledColor,
                          shape: BoxShape.circle,
                        ),
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Padding(
                            padding: EdgeInsets.all(5), // 아이콘 주변 여백 조절
                            child: Icon(Icons.close, color: Colors.white, size: 25),
                          ),
                        ),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      stretchModes: const [
                        StretchMode.zoomBackground,
                        StretchMode.fadeTitle,
                      ],
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (imageUrl.isNotEmpty)
                            CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[300],
                                child: const Center(child: CircularProgressIndicator()),
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.broken_image,
                                size: 100,
                                color: Colors.grey,
                              ),
                            )
                          else
                            Container(color: Colors.grey[300]),
                          // 그라데이션 추가
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.4),
                                  Colors.black.withOpacity(0.3),
                                  Colors.black.withOpacity(0.15),
                                  Colors.black.withOpacity(0.4),
                                  Colors.black.withOpacity(0.5),
                                ],
                                stops: [0.0, 0.2, 0.5, 0.8, 1.0],
                                tileMode: TileMode.clamp,
                              ),
                            ),
                          ),
                        ],
                      ),
                      centerTitle: false,
                      titlePadding: const EdgeInsets.only(left: 16, bottom: 12),
                      title: SafeArea(
                        bottom: false,
                        child: OverflowBox(
                          alignment: Alignment.bottomLeft,
                          maxHeight: double.infinity,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  height: 1.2,
                                  color: Colors.white,
                                  shadows: const [
                                    Shadow(blurRadius: 8, color: Colors.black54, offset: Offset(0, 2)),
                                  ],
                                ),
                              ),
                              Text(
                                plant.plntbneNm ?? '',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 14,
                                  height: 1.2,
                                  color: Colors.white70,
                                  shadows: const [
                                    Shadow(blurRadius: 8, color: Colors.black54, offset: Offset(0, 2)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // 특징 태그
                          if (featureTags.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: featureTags.map((tag) {
                                  return Chip(
                                    label: Text(
                                      tag.label,
                                      style: theme.textTheme.labelMedium?.copyWith(color: Colors.grey[600])
                                    ),
                                    backgroundColor: Colors.grey[200],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                      side: BorderSide(color: theme.dividerColor, width: 0.5),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  );
                                }).toList(),
                              )
                            ),

                          // 간단한 정보글
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                            child: Text(
                              PlantUtils.generateBriefInfo(plant),
                              style: theme.textTheme.titleMedium,
                            ),
                          ),

                          // 특별 관리 정보 (접기/펴기)
                          if (hasSpecialManageInfo)
                          // 특별 관리 정보 (접기/펴기)
                            if (hasSpecialManageInfo)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                  child: Theme(
                                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                    child: ExpansionTile(
                                      childrenPadding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                                      title: Row(
                                        children: [
                                          Icon(Icons.info_rounded, color: theme.hintColor,),
                                          SizedBox(width: 10.0,),
                                          Text(
                                            '관리 Tip',
                                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      collapsedShape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
                                      collapsedBackgroundColor: theme.cardColor,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                          child: Text(
                                            plant.speclmanageInfo ?? "",
                                            style: theme.textTheme.labelMedium,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                          // 상세 내용
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                            child: GridView.count(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1.2, // 카드 높이 확보용
                              // Adjust as needed
                              children: [
                                PlantGridInfoCard(
                                  title: '물주기',
                                  value: PlantUtils
                                      .mapWaterCycleCodeToDescription(
                                      PlantUtils.getCurrentSeasonWaterCycleCode(
                                          plant)),
                                  icon: Icons.water_drop,
                                  onTap: (){},
                                ),
                                PlantGridInfoCard(
                                  title: '광도',
                                  value: PlantUtils.mapLightDemandNames(
                                      plant.lighttdemanddoCodeNm),
                                  icon: Icons.wb_sunny,
                                  onTap: (){},
                                ),
                                PlantGridInfoCard(
                                  title: '관리 수준',
                                  value: PlantUtils.mapManageDemandLevel(
                                      plant.managedemanddoCodeNm),
                                  icon: Icons.star_half,
                                  onTap: (){},
                                ),
                                PlantGridInfoCard(
                                  title: '생육 온도',
                                  value: plant.grwhTpCodeNm ?? '정보 없음',
                                  icon: Icons.thermostat,
                                  onTap: (){},
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          Divider(
                            height: 20.0,
                            thickness: 10.0,
                            color: theme.dividerColor,
                          ),

                          const SizedBox(height: 10),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                            child: Column(
                              children: [
                                PlantDetailInfoSection(
                                  title: '원산지',
                                  value: plant.orgplceInfo ?? '정보 없음',
                                  icon: Icons.location_on,
                                ),
                                PlantDetailInfoSection(
                                  title: '과명',
                                  value: plant.fmlCodeNm ?? '정보 없음',
                                  icon: Icons.category,
                                ),
                                PlantDetailInfoSection(
                                  title: '생육 형태',
                                  value: PlantUtils.mapGrowthStyleNames(
                                      plant.grwhstleCodeNm) ?? '정보 없음',
                                  icon: Icons.nature,
                                ),
                                PlantDetailInfoSection(
                                  title: '습도',
                                  value: plant.hdCodeNm ?? '정보 없음',
                                  icon: Icons.opacity,
                                ),
                              ],
                            ),
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
                color: Colors.black.withOpacity(0.8), // 연한 primary 컬러 배경
                borderRadius: BorderRadius.circular(30), // 캡슐 모양 둥글게
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () async {
                    final user = await UserPrefs.getUser();
                    if (user != null) {
                      _showRegisterModal(context, state.plant);
                    } else {
                      showToastMessage(message: "유저 정보가 없어, 식물을 저장할 수 없어요");
                    }
                  },
                  splashColor: theme.primaryColor.withOpacity(0.3),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 24),
                        SizedBox(width: 8),
                        Text(
                            '식물 등록',
                            style: theme.textTheme.labelMedium?.copyWith(color: Colors.white)
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
