import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/components/custom_scaffold.dart';
import 'package:tium/core/app_info/app_info_cubit.dart';
import 'package:tium/core/constants/constants.dart';
import 'package:tium/core/routes/routes.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        scrolledUnderElevation: 0,
        leadingWidth: 200.0,
        leading: Align(
          alignment: Alignment.centerLeft, // 세로축 중앙, 가로축 왼쪽 정렬
          child: Padding(
            padding: const EdgeInsets.only(left: 13.0), // 좌측 여백 조정
            child: Text('마이페이지', style: Theme.of(context).textTheme.labelLarge),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildSectionTitle(context: context, title: '앱 설정'),
              _buildListTile(
                context: context,
                title: '기본 테마',
                onTap: () {
                  Navigator.of(context).pushNamed(Routes.theme);
                },
              ),

              Divider(
                height: 20.0,
                thickness: 15.0,
                color: Theme.of(context).cardColor,
              ),

              _buildSectionTitle(context: context, title: '약관 및 라이선스'),

              _buildListTile(
                context: context,
                title: '이용약관',
                onTap: () {
                  Navigator.pushNamed(context, Routes.webView, arguments: WebRoutes.termsOfUse);
                },
              ),
              _buildListTile(
                context: context,
                title: '개인정보 처리방침',
                onTap: () {
                  Navigator.pushNamed(context, Routes.webView, arguments: WebRoutes.privacyPolicy);
                },
              ),
              _buildListTile(
                context: context,
                title: '오픈소스 라이선스',
                onTap: () {
                  Navigator.pushNamed(context, Routes.openSource);
                },
              ),

              Divider(
                height: 20.0,
                thickness: 15.0,
                color: Theme.of(context).cardColor,
              ),
              BlocBuilder<AppInfoCubit, String>(
                builder: (context, version) {
                  return _buildListTile(
                      context: context,
                      title: '앱 버전',
                      onTap: () {},
                      trailing: Text('v${version}'));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakCard() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: 16.0, vertical: 16.0),
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('데일리 로또와 함께한지',
                    style: TextStyle(fontSize: 14, color: Colors.black54)),
                SizedBox(height: 4),
                Text('25일째',
                    style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8.0),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle({required String title, required BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16.0, vertical: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }

  Widget _buildListTile(
      {required BuildContext context, required String title, required VoidCallback onTap, Widget? trailing}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
            trailing ?? const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}