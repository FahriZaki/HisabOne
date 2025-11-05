class RmPriorityActivity {
  final String marketingCode;
  final String nama;
  final String posisi;
  final String kodeCabang;
  final String namaCabang;
  final String region;

  final int todayActivity;
  final String statusActivity;
  final int totVisit;
  final double mtdAvgVisit;
  final int totCall;
  final double mtdAvgCall;
  final int mtdSubmission;
  final int mtdNtb;
  final double fundGrowth;

  RmPriorityActivity({
    required this.marketingCode,
    required this.nama,
    required this.posisi,
    required this.kodeCabang,
    required this.namaCabang,
    required this.region,
    required this.todayActivity,
    required this.statusActivity,
    required this.totVisit,
    required this.mtdAvgVisit,
    required this.totCall,
    required this.mtdAvgCall,
    required this.mtdSubmission,
    required this.mtdNtb,
    required this.fundGrowth,
  });

  factory RmPriorityActivity.fromJson(Map<String, dynamic> json) {
    return RmPriorityActivity(
      marketingCode: json["MARKETING_CODE"] ?? "",
      nama: json["NAMA"] ?? "",
      posisi: json["POSISI"] ?? "",
      kodeCabang: json["KODE_CABANG"] ?? "",
      namaCabang: json["NAMA_CABANG"] ?? "",
      region: json["REGION"] ?? "",
      todayActivity: int.tryParse(json["TODAY_ACTIVITY"].toString()) ?? 0,
      statusActivity: json["STATUS_ACTIVITY"] ?? "",
      totVisit: int.tryParse(json["TOT_VISIT"].toString()) ?? 0,
      mtdAvgVisit: double.tryParse(json["MTD_AVG_VISIT"].toString()) ?? 0.0,
      totCall: int.tryParse(json["TOT_CALL"].toString()) ?? 0,
      mtdAvgCall: double.tryParse(json["MTD_AVG_CALL"].toString()) ?? 0.0,
      mtdSubmission: int.tryParse(json["MTD_SUBMISSION"].toString()) ?? 0,
      mtdNtb: int.tryParse(json["MTD_NTB"].toString()) ?? 0,
      fundGrowth: double.tryParse(json["FUND_GROWTH"].toString()) ?? 0.0,
    );
  }
}
