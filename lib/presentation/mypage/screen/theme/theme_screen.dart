import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/components/custom_scaffold.dart';
import 'package:tium/presentation/main/bloc/theme_bloc/theme_bloc.dart';
import 'package:tium/presentation/main/bloc/theme_bloc/theme_event.dart';
import 'package:tium/presentation/main/bloc/theme_bloc/theme_state.dart';

class ThemeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        scrolledUnderElevation: 0,
        title: Text(
          '기본 테마 설정',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      body: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          final currentThemeMode = (state is ThemeInitial) ? state.themeMode : ThemeMode.system;

          return ListView.separated(
            itemCount: 3,
            separatorBuilder: (context, index) => Divider(height: 1, thickness: 0.5, color: Theme.of(context).cardColor, endIndent: 15.0, indent: 15.0,),
            itemBuilder: (context, index) {
              final List<Map<String, dynamic>> themeModes = [
                {'title': '시스템 모드', 'mode': ThemeMode.system},
                {'title': '라이트 모드', 'mode': ThemeMode.light},
                {'title': '다크 모드', 'mode': ThemeMode.dark},
              ];

              return ListTile(
                title: Text(
                  themeModes[index]['title'] as String,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400),
                ),
                leading: Radio<ThemeMode>(
                  value: themeModes[index]['mode'],
                  groupValue: currentThemeMode,
                  onChanged: (value) {
                    if (value != null) {
                      context.read<ThemeBloc>().add(ThemeChanged(themeMode: value));
                    }
                  },
                  activeColor: Theme.of(context).primaryColor,
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