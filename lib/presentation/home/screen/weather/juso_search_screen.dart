import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:tium/components/custom_scaffold.dart';
import 'package:tium/core/di/locator.dart';
import 'package:tium/presentation/home/bloc/juso_search/juso_search_cubit.dart';
import 'package:tium/presentation/home/bloc/location/location_search_bloc.dart';
import 'package:tium/presentation/home/bloc/location/location_search_event.dart';
import 'package:tium/presentation/home/bloc/location/location_search_state.dart';

class JusoSearchScreen extends StatefulWidget {
  const JusoSearchScreen({super.key});

  @override
  State<JusoSearchScreen> createState() => _JusoSearchScreenState();
}

class _JusoSearchScreenState extends State<JusoSearchScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<JusoSearchCubit>().clearSearch();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomScaffold(
      appBarVisible: true,
      title: '주소 검색',
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocListener<LocationBloc, LocationState>(
        listener: (context, state) {
          if (state is LocationLoadSuccess) {
            Navigator.pop(context, state.location); // 위치 반환 후 pop
          } else if (state is LocationLoadFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: '도로명 또는 지번을 입력하세요',
                  hintStyle: theme.textTheme.bodyMedium,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search, color: theme.colorScheme.primary),
                    onPressed: () {
                      final keyword = _controller.text.trim();
                      if (keyword.isNotEmpty) {
                        context.read<JusoSearchCubit>().search(keyword);
                      }
                    },
                  ),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    context.read<JusoSearchCubit>().search(value.trim());
                  }
                },
              ),
              const SizedBox(height: 12),

              Expanded(
                child: BlocBuilder<JusoSearchCubit, JusoSearchState>(
                  builder: (context, state) {
                    if (state is JusoSearchLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is JusoSearchError) {
                      return Center(child: Text(state.message));
                    }
                    if (state is JusoSearchLoaded) {
                      if (state.results.isEmpty) {
                        return const Center(child: Text('검색 결과가 없습니다'));
                      }
                      return ListView.separated(
                        itemCount: state.results.length,
                        separatorBuilder: (_, __) =>
                            Divider(height: 10.0,
                                thickness: 1.0,
                                color: theme.colorScheme.tertiary),
                        itemBuilder: (_, index) {
                          final r = state.results[index];
                          final fullAddress = r.roadAddr.isNotEmpty ? r.roadAddr : r.jibunAddr;
                          return ListTile(
                            title: Text(fullAddress, style: theme.textTheme.titleSmall,),
                            subtitle: Text('${r.siNm} ${r.sggNm} ${r.emdNm}${r.liNm != null && r.liNm!.isNotEmpty ? ' ${r.liNm}' : ''}', style: theme.textTheme.bodySmall,),
                            onTap: () {
                              // LocationBloc에 주소 → 좌표 요청
                              context.read<LocationBloc>().add(
                                LocationByAddressRequested(fullAddress),
                              );
                            },
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}