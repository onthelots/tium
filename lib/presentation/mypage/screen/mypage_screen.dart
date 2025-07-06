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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.dividerColor,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        title: Text('마이페이지', style: theme.textTheme.labelLarge,),
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
              _buildListTile(
                context: context,
                title: '알림 시간 설정',
                onTap: () {
                  Navigator.of(context).pushNamed(Routes.notificationTimeSetting);
                },
              ),

              Divider(
                height: 20.0,
                thickness: 10.0,
                color: theme.dividerColor,
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
                thickness: 10.0,
                color: theme.dividerColor,
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

  Widget _buildSectionTitle({required String title, required BuildContext context}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16.0, vertical: 16.0),
      child: Text(
        title,
        style: theme.textTheme.labelMedium,
      ),
    );
  }

  Widget _buildListTile(
      {required BuildContext context, required String title, required VoidCallback onTap, Widget? trailing}) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: theme.textTheme.bodyMedium),
            trailing ?? const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}