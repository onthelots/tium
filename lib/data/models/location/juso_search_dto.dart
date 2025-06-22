class JusoSearchResult {
  final String roadAddr;
  final String jibunAddr;
  final String admCd;
  final String siNm;
  final String sggNm;
  final String emdNm;
  final String? liNm;

  JusoSearchResult({
    required this.roadAddr,
    required this.jibunAddr,
    required this.admCd,
    required this.siNm,
    required this.sggNm,
    required this.emdNm,
    this.liNm,
  });

  factory JusoSearchResult.fromJson(Map<String, dynamic> json) {
    return JusoSearchResult(
      roadAddr: json['roadAddr'],
      jibunAddr: json['jibunAddr'],
      admCd: json['admCd'],
      siNm: json['siNm'],
      sggNm: json['sggNm'],
      emdNm: json['emdNm'],
      liNm: json['liNm'],
    );
  }
}