import 'package:Billy/enums/log_level_enum.dart';
import 'package:Billy/local/database/app_database.dart';

class LogModel {
  final String userId;
  final String message;
  final LogLevelEnum level;
  final DateTime createdAt;

  const LogModel({
    required this.userId,
    required this.message,
    required this.level,
    required this.createdAt,
  });

  // Da Drift → utile per sync col BE
  factory LogModel.fromTableData(LogsTableData data) => LogModel(
    userId: data.userId,
    message: data.message,
    level: LogLevelEnum.values.firstWhere((e) => e.value == data.level, orElse: () => LogLevelEnum.INFO),
    createdAt: data.createdAt,
  );
}