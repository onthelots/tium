import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/components/custom_scaffold.dart';
import 'package:tium/presentation/main/bloc/theme_bloc/theme_bloc.dart';
import 'package:tium/presentation/main/bloc/theme_bloc/theme_event.dart';
import 'package:tium/presentation/main/bloc/theme_bloc/theme_state.dart';

class ThemeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomScaffold(
      appBarVisible: true,
      title: '기본 테마 설정',
      body: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          final currentThemeMode = (state is ThemeInitial) ? state.themeMode : ThemeMode.system;

          return ListView.separated(
            itemCount: 3,
            separatorBuilder: (context, index) => Divider(height: 5, thickness: 0.0, color: theme.scaffoldBackgroundColor,),
            itemBuilder: (context, index) {
              final List<Map<String, dynamic>> themeModes = [
                {'title': '시스템 모드', 'mode': ThemeMode.system},
                {'title': '라이트 모드', 'mode': ThemeMode.light},
                {'title': '다크 모드', 'mode': ThemeMode.dark},
              ];

              return ListTile(
                title: Text(
                  themeModes[index]['title'] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400),
                ),
                leading: Radio<ThemeMode>(
                  value: themeModes[index]['mode'],
                  groupValue: currentThemeMode,
                  onChanged: (value) {
                    if (value != null) {
                      context.read<ThemeBloc>().add(ThemeChanged(themeMode: value));
                    }
                  },
                  activeColor: theme.primaryColor,
                ),
                onTap: () {
                  context.read<ThemeBloc>().add(ThemeChanged(themeMode: themeModes[index]['mode']));
                },
              );
            },
          );
        },
      ),
    );
  }
}