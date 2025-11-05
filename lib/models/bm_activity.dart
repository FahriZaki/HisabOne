class BmActivity {
  final String nama;
  final String namaCabang;
  final String region;
  final String bmLoginDtd;
  final String rmLoginDtd;
  final String avgVisit;
  final int mtdVisit;
  final String avgCall;
  final int mtdCall;

  BmActivity({
    required this.nama,
    required this.namaCabang,
    required this.region,
    required this.bmLoginDtd,
    required this.rmLoginDtd,
    required this.avgVisit,
    required this.mtdVisit,
    required this.avgCall,
    required this.mtdCall,
  });

  factory BmActivity.fromJson(Map<String, dynamic> json) {
    return BmActivity(
      nama: json["NAMA"] ?? "",
      namaCabang: json["NAMA_CABANG"] ?? "",
      region: json["REGION"] ?? "",
      bmLoginDtd: json["bm_login_dtd"]?.toString() ?? "",
      rmLoginDtd: json["login_rm_dtd"]?.toString() ?? "",
      avgVisit: json["AVG_VISIT"]?.toString() ?? "",
      mtdVisit: int.tryParse(json['MTD_VISIT'].toString()) ?? 0, 
      avgCall: json["AVG_CALL"]?.toString() ?? "",
      mtdCall: int.tryParse(json['MTD_CALL'].toString()) ?? 0,
    );
  }
}
