import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class WelcomeLandingCard extends StatelessWidget {
  final VoidCallback onPressed;

  const WelcomeLandingCard({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Map<String, dynamic>> exampleSlides = [
      {
        'title': '실시간 날씨 정보',
        'subtitle': '현재 위치 기준으로 온도, 자외선 정보를 알려드려요.',
        'icon': Icons.wb_sunny,
        'color': theme.focusColor,
        'tag': '#실시간날씨',
      },
      {
        'title': '나에게 꼭 맞는 식물 추천',
        'subtitle': '당신의 생활패턴과 환경에 딱 맞는 식물을 찾아드릴게요.',
        'icon': Icons.recommend,
        'color': theme.highlightColor,
        'tag': '#맞춤추천',
      },
      {
        'title': '물 주기 알림 & 관리',
        'subtitle': '언제 물 줘야 할지, 어떻게 관리해야 할지 알려드릴게요.',
        'icon': Icons.water_drop,
        'color': theme.primaryColor,
        'tag': '#식물관리',
      },
    ];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Card(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '앱의 모든 기능을 제대로 사용하려면\n당신의 취향을 알려주세요!',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -1.0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 슬라이더 높이 고정, 내부는 유연하게
                CarouselSlider(
                  options: CarouselOptions(
                    height: 200,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    viewportFraction: 0.85,
                    autoPlayInterval: const Duration(seconds: 3),
                    autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  ),
                  items: exampleSlides.map((slide) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          decoration: BoxDecoration(
                            color: slide['color'] ?? theme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(slide['icon'],
                                  size: 64, color: theme.disabledColor),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      slide['title'],
                                      style: theme.textTheme.titleSmall?.copyWith(letterSpacing: -1.3, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),

                                    // subtitle
                                    Flexible(
                                      child: Text(
                                        slide['subtitle'],
                                        style: theme.textTheme.labelMedium,
                                        softWrap: true,
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    // tag
                                    Text(
                                      slide['tag'],
                                      style: theme.textTheme.labelSmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '간단한 질문에 답변을 해주세요\n당신의 식물키우기 타입을 알려드릴게요',
                      style: theme.textTheme.bodyMedium,
                    ),

                    const SizedBox(height: 16),

                    ElevatedButton.icon(
                      icon: const Icon(Icons.settings, size: 20.0,),
                      label: const Padding(
                        padding:
                        EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                        child: Text(
                          '내 정보 설정하기',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                        shadowColor: theme.colorScheme.primary.withOpacity(0.4),
                      ),
                      onPressed: onPressed,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
