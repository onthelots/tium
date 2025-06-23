import 'dart:math';

class LatLngGridConverter {
  static const double _RE = 6371.00877; // 지구 반경(km)
  static const double _GRID = 5.0;      // 격자 간격(km)
  static const double _SLAT1 = 30.0;    // 투영 위도1(degree)
  static const double _SLAT2 = 60.0;    // 투영 위도2(degree)
  static const double _OLON = 126.0;    // 기준점 경도(degree)
  static const double _OLAT = 38.0;     // 기준점 위도(degree)
  static const double _XO = 43;         // 기준점 X좌표(GRID)
  static const double _YO = 136;        // 기준점 Y좌표(GRID)

  static const double _DEGRAD = pi / 180.0;

  static GridCoord latLngToGrid(double lat, double lon) {
    final re = _RE / _GRID;
    final slat1 = _SLAT1 * _DEGRAD;
    final slat2 = _SLAT2 * _DEGRAD;
    final olon = _OLON * _DEGRAD;
    final olat = _OLAT * _DEGRAD;

    double sn = tan(pi * 0.25 + slat2 * 0.5) / tan(pi * 0.25 + slat1 * 0.5);
    sn = log(cos(slat1) / cos(slat2)) / log(sn);

    double sf = tan(pi * 0.25 + slat1 * 0.5);
    sf = pow(sf, sn) * cos(slat1) / sn;

    double ro = tan(pi * 0.25 + olat * 0.5);
    ro = re * sf / pow(ro, sn);

    double ra = tan(pi * 0.25 + lat * _DEGRAD * 0.5);
    ra = re * sf / pow(ra, sn);

    double theta = lon * _DEGRAD - olon;
    if (theta > pi) theta -= 2.0 * pi;
    if (theta < -pi) theta += 2.0 * pi;
    theta *= sn;

    int nx = (ra * sin(theta) + _XO + 0.5).floor();
    int ny = (ro - ra * cos(theta) + _YO + 0.5).floor();

    return GridCoord(x: nx, y: ny);
  }
}

class GridCoord {
  final int x;
  final int y;
  const GridCoord({required this.x, required this.y});
}
