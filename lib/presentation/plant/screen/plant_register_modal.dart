import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path;
import 'package:tium/components/custom_toast_message.dart';
import 'package:tium/components/image_utils.dart';
import 'package:tium/core/services/hive/onboarding/onboarding_prefs.dart';
import 'package:tium/data/models/plant/plant_detail_api_model.dart';
import 'package:tium/data/models/user/user_model.dart';
import 'package:tium/presentation/management/bloc/user_plant_bloc.dart';
import 'package:tium/presentation/management/bloc/user_plant_event.dart';
import 'package:tium/presentation/management/utils/image_picker_helper.dart';
import 'package:tium/presentation/plant/utils/plant_detail_utils.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

class PlantRegisterModal extends StatefulWidget {
  final PlantDetailApiModel plant;

  const PlantRegisterModal({
    super.key,
    required this.plant,
  });

  @override
  State<PlantRegisterModal> createState() => _PlantRegisterModalState();
}

class _PlantRegisterModalState extends State<PlantRegisterModal> {
  final _nameController = TextEditingController();
  final List<String> _allLocations = ['거실', '주방', '침실', '베란다', '욕실', '서재', '현관', '기타'];
  List<String> _selectedLocations = [];

  bool _isNameValid = false;
  bool _isDuplicateName = false;

  String? _pickedImageRelativePath; // File? -> String? (상대 경로)

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.plant.plntzrNm ?? ''; // Use plntzrNm
    _checkNameValid(_nameController.text);

    _nameController.addListener(() {
      _checkNameValid(_nameController.text);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _checkNameValid(String name) async {
    final trimmed = name.trim();
    final user = await UserPrefs.getUser();
    final isDuplicate = user?.indoorPlants.any((p) => p.name == trimmed) ?? false;

    final isValid = trimmed.isNotEmpty && !isDuplicate;

    if (isValid != _isNameValid || isDuplicate != _isDuplicateName) {
      setState(() {
        _isNameValid = isValid;
        _isDuplicateName = isDuplicate;
      });
    }
  }

  void _toggleLocation(String loc) {
    setState(() {
      if (_selectedLocations.contains(loc)) {
        _selectedLocations.remove(loc);
      } else {
        _selectedLocations.add(loc);
      }
    });
  }

  Widget _buildLocationSelector() {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _allLocations.map((loc) {
        final isSelected = _selectedLocations.contains(loc);
        final backgroundColor = isSelected ? theme.colorScheme.primary : theme.cardColor;
        final textColor = isSelected ? Colors.white : Colors.grey;
        final fontWeight = isSelected ? FontWeight.bold : FontWeight.normal;

        return GestureDetector(
          onTap: () => _toggleLocation(loc),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              loc,
              style: TextStyle(color: textColor, fontWeight: fontWeight),
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();

    if (name.isEmpty || _selectedLocations.isEmpty) {
      return; // 버튼 비활성화 상태에서는 호출 안 됨. 혹시 몰라서 double-check.
    }

    final user = await UserPrefs.getUser();
    if (user == null) {
      if (!mounted) return; // mounted 체크 추가
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용자 정보를 불러올 수 없습니다.')),
      );
      return;
    }

    final isDuplicate = user.indoorPlants.any((p) => p.name == name);
    if (isDuplicate) {
      showToastMessage(message: '이미 등록된 이름입니다. 다른 이름을 입력해주세요.');
      _nameController.clear();
      setState(() {
        _isNameValid = false;
        _isDuplicateName = true;
      });
      return;
    }

    print("현재 날짜에 따른 계절별 물주기 : ${PlantUtils.getCurrentSeasonWaterCycleCode(widget.plant)}");
    print("물주기 - 주기는? : ${PlantUtils.getWateringIntervalDays(PlantUtils.getCurrentSeasonWaterCycleCode(widget.plant))}");


    final newPlant = UserPlant(
      id: Uuid().v4(),
      name: name,
      scientificName: widget.plant.plntbneNm ?? '',
      // 기존 필드 유지 (PlantDetailApiModel에서 파생)
      difficulty: widget.plant.managelevelCodeNm ?? '정보 없음', // managelevelCodeNm 사용
      wateringCycle: PlantUtils.getCurrentSeasonWaterCycleCode(widget.plant), // 새로운 헬퍼 함수 사용
      isWateringNotificationOn: false,
      registeredDate: DateTime.now(),
      lastWateredDate: DateTime.now(),
      wateringIntervalDays: PlantUtils.getWateringIntervalDays(PlantUtils.getCurrentSeasonWaterCycleCode(widget.plant)), // Use current season's water code
      notificationId: null,
      imagePath: _pickedImageRelativePath, // 상대 경로 할당
      locations: _selectedLocations,
      cntntsNo: widget.plant.cntntsNo ?? '',
      // 새로 추가된 필드들
      waterCycleSpring: widget.plant.watercycleSprngCodeNm,
      waterCycleSummer: widget.plant.watercycleSummerCodeNm,
      waterCycleAutumn: widget.plant.watercycleAutumnCodeNm,
      waterCycleWinter: widget.plant.watercycleWinterCodeNm,
      manageLevel: widget.plant.managelevelCodeNm,
    );

    context.read<UserPlantBloc>().add(AddPlant(newPlant));
    Navigator.of(context).pop();

    showToastMessage(message: '등록이 완료되었습니다.');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRegisterEnabled = _isNameValid && _selectedLocations.isNotEmpty;

    return Material(
      color: theme.scaffoldBackgroundColor,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '내 식물 등록하기',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 28),
                      GestureDetector(
                        onTap: () => pickImageFromGallery(context, (relativePath) {
                          setState(() => _pickedImageRelativePath = relativePath);
                        }),
                        child: Container(
                          height: 160,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.colorScheme.primary, width: 1.5),
                            color: theme.colorScheme.surfaceVariant.withOpacity(0.1),
                          ),
                          child: _pickedImageRelativePath != null
                              ? FutureBuilder<File>(
                                  future: getImageFileFromRelativePath(_pickedImageRelativePath!),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(snapshot.data!, fit: BoxFit.cover),
                                      );
                                    } else if (snapshot.hasError) {
                                      return buildImagePlaceholder(context);
                                    } else {
                                      return const Center(child: CircularProgressIndicator());
                                    }
                                  },
                                )
                              : buildImagePlaceholder(context),
                        ),
                      ),
                      const SizedBox(height: 28),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: "식물 이름 혹은 별명을 입력해주세요",
                          hintStyle: theme.textTheme.bodyMedium,
                          labelText: '식물 이름',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorText: _isDuplicateName ? '이미 등록된 이름입니다.' : null,
                        ),
                        maxLength: 20,
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      Text('식물 위치 선택 (중복 가능)', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 8),
                      _buildLocationSelector(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: isRegisterEnabled ? _register : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  backgroundColor: isRegisterEnabled ? theme.colorScheme.primary : theme.disabledColor,
                ),
                child: Text('등록하기', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}