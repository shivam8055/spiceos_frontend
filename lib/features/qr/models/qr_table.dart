class QRTable {
  const QRTable({
    required this.id,
    required this.tableId,
    required this.tableName,
    required this.branchId,
    required this.sessionId,
    required this.qrToken,
    required this.qrUrl,
  });

  final int id;
  final String tableId;
  final String tableName;
  final String branchId;
  final String sessionId;
  final String qrToken;
  final String qrUrl;

  factory QRTable.fromJson(Map<String, dynamic> json) => QRTable(
        id: json['id'] as int,
        tableId: json['table_id'] as String,
        tableName: json['table_name'] as String,
        branchId: json['branch_id'] as String,
        sessionId: json['session_id'] as String,
        qrToken: json['qr_token'] as String,
        qrUrl: json['qr_url'] as String,
      );
}
