import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tium/core/constants.dart';
import 'package:tium/core/services/hive/hive_prefs.dart';
import 'package:tium/core/services/hive/onboarding/onboarding_prefs.dart';
import 'package:tium/core/services/shared_preferences_helper.dart';
import 'package:tium/data/models/user/user_model.dart';
import 'package:tium/presentation/home/bloc/weather/weather_bloc.dart';
import 'package:tium/presentation/home/bloc/weather/weather_state.dart';

/// HomeScreen – Sliver 기반 메인 탭
///
/// ▸ 공공데이터 사용처
///   1. 기상청 생활기상지수 API → WeatherRepository
///   2. 농사로 Garden / 실내정원 API → PlantRepository
///   3. 농촌진흥청 병해충 API      → PestRepository
///   4. 모두농(농정원) 행사 RSS    → EventRepository
///
/// 이 예시는 UI/UX·색상 가이드에 집중하고, 실제 네트워크 코드/파싱은
///

class WeatherRepository {
  Future<WeatherData> fetchCurrent(String regionCode) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return WeatherData(temperature: "25", uvIndex: "6 (보통)");
  }
}

class PlantRepository {
  Future<List<Plant>> recommendForUser(UserModel user) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      Plant(name: "스투키", imageUrl: ""),
      Plant(name: "산세베리아", imageUrl: ""),
      Plant(name: "아글라오네마", imageUrl: ""),
    ];
  }

  Future<List<Tip>> tipsForUser(UserModel user) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      Tip(title: "햇빛 없이 키우는 법", description: "창문 없이도 잘 자라는 식물 정리"),
      Tip(title: "배양토 종류 총정리", description: "초보자도 이해하는 흙 가이드"),
    ];
  }
}

class PestRepository {
  Future<PestAlert> fetchCurrentAlert(String regionCode) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return PestAlert(
      title: "응애 발생 위험 ↑",
      message: "잎 뒷면을 주기적으로 확인하세요 (6월 19일 기준)",
    );
  }
}

class EventRepository {
  Future<EventItem> fetchUpcoming({String? city}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return EventItem(
      title: "서울 도시농업박람회",
      period: "6월 30일 ~ 7월 2일 / 무료 사전신청",
    );
  }
}


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;
  String _regionLabel = "서울";
  UserModel? _user;
  WeatherData? _weather;
  List<Plant> _recommendedPlants = [];
  List<Tip> _tips = [];
  PestAlert? _pestAlert;
  EventItem? _event;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _fetchAll();
  }

  void _handleScroll() {
    if (_scrollController.hasClients && _scrollController.offset > 100) {
      if (!_isCollapsed) setState(() => _isCollapsed = true);
    } else {
      if (_isCollapsed) setState(() => _isCollapsed = false);
    }
  }

  Future<void> _fetchAll() async {
    _user = await UserPrefs.getUser();
    if (_user == null) return;

    // 지역코드 & 라벨 가져오기 (없다면 기본값 사용)
    final regionCode =
        await SharedPreferencesHelper.getWeatherRegionCode() ?? '11B10101';
    _regionLabel =
        await SharedPreferencesHelper.getWeatherRegionLabel() ?? "서울";

    final plantRepo = PlantRepository();
    final pestRepo = PestRepository();
    final eventRepo = EventRepository();

    await Future.wait([
      plantRepo.recommendForUser(_user!).then((p) => _recommendedPlants = p),
      plantRepo.tipsForUser(_user!).then((t) => _tips = t),
      pestRepo.fetchCurrentAlert(regionCode).then((a) => _pestAlert = a),
      eventRepo.fetchUpcoming(city: '서울').then((e) => _event = e),
    ]);

    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          BlocBuilder<WeatherBloc, WeatherState>(
            builder: (context, state) => _buildSliverAppBar(theme, state),
          ),
          _buildRecommendedSection(),
          _buildTipSection(),
          if (_pestAlert != null) _buildPestSection(),
          if (_event != null) _buildEventSection(),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────── SliverAppBar
  SliverAppBar _buildSliverAppBar(ThemeData theme, WeatherState state) {
    String temp = '--';
    String uv   = '--';
    if (state is WeatherLoaded) {
      temp = state.uvIndex.value.toString() ?? '--'; // assume added field or separate API
      uv   = _interpretUVLevel(state.uvIndex.value);
    }

    return SliverAppBar(
      pinned: true,
      expandedHeight: 150,
      centerTitle: true,
      backgroundColor: AppColors.lightPrimary,
      title: _isCollapsed
          ? Text('$_regionLabel · $temp°C  ☀  자외선지수 $uv',
          style: theme.textTheme.labelMedium?.copyWith(color: Colors.white))
          : null,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Container(
          decoration: BoxDecoration(
            color: theme.primaryColor,
          ),
          padding: const EdgeInsets.only(left: 20, bottom: 20),
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('안녕하세요, OOO님',
                  style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white)),
              const SizedBox(height: 6),
              Text('$_regionLabel · $temp°C  ☀  자외선지수 $uv',
                  style: theme.textTheme.labelMedium?.copyWith(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  String _interpretUVLevel(int uv) {
    if (uv < 3) return '낮음';
    if (uv < 6) return '보통';
    if (uv < 8) return '높음';
    if (uv < 11) return '매우 높음';
    return '위험';
  }

  // ────────── 추천 식물 ──────────
  SliverToBoxAdapter _buildRecommendedSection() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('오늘의 추천 식물 🌿'),
          SizedBox(
            height: 180,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) => _PlantCard(_recommendedPlants[i]),
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: _recommendedPlants.length.clamp(0, 10),
            ),
          ),
        ],
      ),
    );
  }

  // ────────── TIP 섹션 ──────────
  SliverToBoxAdapter _buildTipSection() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('실내 정원 TIP 🪴'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: _tips.map((t) => _TipCard(t)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ────────── 병해충 ──────────
  SliverToBoxAdapter _buildPestSection() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('병해충 주의보 🐛'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _AlertCard(_pestAlert!),
          ),
        ],
      ),
    );
  }

  // ────────── 행사 ──────────
  SliverToBoxAdapter _buildEventSection() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('도시농업 행사 📅'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _EventCard(_event!),
          ),
        ],
      ),
    );
  }

  // 공통 섹션 타이틀
  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
    child: Text(text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightPrimary)),
  );
}

// ──────────────────────────────────────────────────────────────
// SMALL COMPONENTS
// ──────────────────────────────────────────────────────────────
class _PlantCard extends StatelessWidget {
  const _PlantCard(this.plant);
  final Plant plant;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: AppColors.lightTertiary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // TODO: 네트워크 이미지로 교체 (plant.imageUrl)
          const Icon(Icons.local_florist, size: 46, color: AppColors.lightPrimary),
          const SizedBox(height: 8),
          Text(plant.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard(this.tip);
  final Tip tip;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.lightAccent.withOpacity(0.4),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.tips_and_updates, color: AppColors.lightPrimary),
        title: Text(tip.title),
        subtitle: Text(tip.description),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard(this.alert);
  final PestAlert alert;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      child: ListTile(
        leading: const Icon(Icons.warning, color: Colors.red),
        title: Text(alert.title),
        subtitle: Text(alert.message),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard(this.event);
  final EventItem event;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.lightSecondary.withOpacity(0.3),
      child: ListTile(
        leading: const Icon(Icons.event, color: AppColors.lightPrimary),
        title: Text(event.title),
        subtitle: Text(event.period),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// DATA CLASSES (요약)
// ──────────────────────────────────────────────────────────────
class WeatherData {
  final String temperature;
  final String uvIndex;
  WeatherData({required this.temperature, required this.uvIndex});
}

class Plant {
  final String name;
  final String imageUrl;
  Plant({required this.name, required this.imageUrl});
}

class Tip {
  final String title;
  final String description;
  Tip({required this.title, required this.description});
}

class PestAlert {
  final String title;
  final String message;
  PestAlert({required this.title, required this.message});
}

class EventItem {
  final String title;
  final String period;
  EventItem({required this.title, required this.period});
}