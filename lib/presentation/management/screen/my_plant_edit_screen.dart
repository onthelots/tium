import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/components/custom_platform_alert_dialog.dart';
import 'package:tium/components/custom_scaffold.dart';
import 'package:tium/components/image_utils.dart';
import 'package:tium/data/models/user/user_model.dart';
import 'package:tium/presentation/management/bloc/user_plant_bloc.dart';
import 'package:tium/presentation/management/bloc/user_plant_event.dart';
import 'package:tium/presentation/management/utils/image_picker_helper.dart';

class MyPlantEditScreen extends StatefulWidget {
  final UserPlant initialPlant;

  const MyPlantEditScreen({super.key, required this.initialPlant});

  @override
  State<MyPlantEditScreen> createState() => _PlantEditModalState();
}

class _PlantEditModalState extends State<MyPlantEditScreen> {
  late TextEditingController _nameController;
  final List<String> _allLocations = ['거실', '주방', '침실', '베란다', '욕실', '서재', '현관', '기타'];
  late List<String> _selectedLocations;

  bool _isNameValid = true;
  String? _pickedImageRelativePath; // File? -> String? (상대 경로)
  Future<File>? _imageFileFuture; // Future 상태 추가

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialPlant.name);
    _selectedLocations = List.from(widget.initialPlant.locations);
    _pickedImageRelativePath = widget.initialPlant.imagePath; // 기존 이미지 경로 초기화

    // 초기 이미지 Future 생성
    if (_pickedImageRelativePath != null) {
      _imageFileFuture = getImageFileFromRelativePath(_pickedImageRelativePath!);
    }

    _nameController.addListener(() {
      final isValid = _nameController.text.trim().isNotEmpty;
      if (isValid != _isNameValid) {
        setState(() {
          _isNameValid = isValid;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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

  Future<void> _updatePlant() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _selectedLocations.isEmpty) return;

    // 기존 알림 상태를 유지하도록 copyWith에 추가
    final updated = widget.initialPlant.copyWith(
      name: name,
      locations: _selectedLocations,
      imagePath: _pickedImageRelativePath,
      isWateringNotificationOn: widget.initialPlant.isWateringNotificationOn,
      notificationId: widget.initialPlant.notificationId,
      nextWateringDate: widget.initialPlant.nextWateringDate,
    );

    print("업데이트 사항 - 물주기 : ${updated.isWateringNotificationOn})");
    print("업데이트 사항 - 이름 : ${updated.name})");

    // Bloc에 업데이트 이벤트 전달
    context.read<UserPlantBloc>().add(UpdatePlant(updated));

    // 화면 종료
    Navigator.pop(context, updated);
  }


  Future<void> _deletePlant() async {
    await showPlatformAlertDialog(
      context: context,
      title: '삭제 확인',
      content: '정말 이 식물을 삭제하시겠어요?',
      confirmText: '삭제',
      cancelText: '취소',
      onConfirm: () {
        context.read<UserPlantBloc>().add(DeletePlant(widget.initialPlant));
        Navigator.pop(context, {'deleted': true});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSaveEnabled = _isNameValid && _selectedLocations.isNotEmpty;

    return CustomScaffold(
      appBarVisible: true,
      title: '내 식물 정보 수정',
      trailing: TextButton(
        onPressed: _deletePlant,
        child: Text('삭제하기',
            style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor, fontWeight: FontWeight.w300)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // 1. 사진
            LayoutBuilder(builder: (context, constraints) {
              final size = constraints.maxWidth;

              return GestureDetector(
                onTap: () => pickImageFromGallery(context, (relativePath) {
                  setState(() {
                    _pickedImageRelativePath = relativePath;
                    if (relativePath != null) {
                      _imageFileFuture = getImageFileFromRelativePath(relativePath);
                    } else {
                      _imageFileFuture = null;
                    }
                  });
                }),
                child: Stack(
                  children: [
                    Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: theme.colorScheme.primary, width: 1.5),
                        color: theme.colorScheme.surfaceVariant.withOpacity(
                            0.1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _imageFileFuture != null
                            ? FutureBuilder<File>(
                          future: _imageFileFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done && snapshot.hasData) {
                              return Image.file(
                                  snapshot.data!, fit: BoxFit.cover);
                            } else if (snapshot.hasError) {
                              return const Center(child: Icon(
                                  Icons.camera_alt_outlined, size: 40));
                            } else {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                          },
                        )
                            : const Center(
                            child: Icon(Icons.camera_alt_outlined, size: 40)),
                      ),

                    ),
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.edit, size: 16, color: Colors.white),
                            SizedBox(width: 4),
                            Text('사진 변경',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                )),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),

            // 식물 이름
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '식물 이름',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),

            // 식물 위치
            Text('식물 위치 (중복 선택 가능)', style: theme.textTheme.titleMedium),
            const SizedBox(height: 10),
            Wrap(
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
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
        child: SafeArea(
          minimum: const EdgeInsets.only(bottom: 0),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isSaveEnabled ? _updatePlant : null,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 4,
              ),
              child: const Text(
                '저장하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
