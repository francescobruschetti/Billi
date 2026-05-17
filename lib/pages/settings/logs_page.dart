import 'package:Billy/constants.dart';
import 'package:Billy/local/database/app_database.dart';
import 'package:Billy/providers/local-database/logs_provider.dart';
import 'package:Billy/utils/generic_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

class LogsPage extends ConsumerStatefulWidget {
  const LogsPage({super.key});

  @override
  ConsumerState<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends ConsumerState<LogsPage> {
  final Logger log = Logger('LogsPage');
  final ScrollController _scrollController = ScrollController();

  String _selectedLevel = 'ALL';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(logsProvider);

    return logsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error loading logs: $e')),
      data: (logs) => _buildLogsList(logs),
    );
  }

  Future<void> _filterLogs(BuildContext context, String level) async {
    await ref.read(logsProvider.notifier).loadUserLogsByLevel(level);
  }

  Future<void> _loadLogs(BuildContext context) async {
    await ref.read(logsProvider.notifier).loadUserLogs();
    if (context.mounted) {
      GenericUtil.showSnackbar(context, 'Logs aggiornati');
    }
  }

  Icon _iconForLogLevel(String level) {
    switch (level) {
      case 'FINER':
        return const Icon(Icons.bug_report, color: Colors.brown);
      case 'FINE':
        return const Icon(Icons.bug_report, color: Colors.blue);
      case 'INFO':
        return const Icon(Icons.info_outline, color: Colors.green);
      case 'WARNING':
        return const Icon(Icons.warning_amber_outlined, color: Colors.orange);
      case 'ERROR':
        return const Icon(Icons.error_outline, color: Colors.red);
      default:
        return const Icon(Icons.help_outline, color: Colors.grey);
    }
  }

  Widget _buildLogsList(List<LogsTableData> logs) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Segnala un problema'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadLogs(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Text('Logs salvati localmente: ${logs.length}', 
              style: const TextStyle(fontSize: AppConstants.textSize, fontWeight: FontWeight.bold)
            ),

            const SizedBox(height: AppConstants.mediumSizedBoxHeight),
            _buildLevelFilterChips(context),
            
            const SizedBox(height: AppConstants.mediumSizedBoxHeight),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _iconForLogLevel(logs[index].level),    

                          const SizedBox(width: AppConstants.mediumSizedBoxWidth),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${logs[index].id} - ${logs[index].message}',
                                  style: const TextStyle(fontSize: 14),
                                ), 

                                const SizedBox(width: AppConstants.mediumSizedBoxWidth),
                                Text(
                                  logs[index].createdAt.toLocal().toIso8601String(),
                                  style: const TextStyle(fontSize: AppConstants.smallTextSize)
                                ),
                              ]
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelFilterChips(BuildContext context) {
    final levels = ['ALL', 'ERROR', 'WARNING', 'INFO', 'FINER', 'FINE'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,

      child: Row(
        children: levels.map((level) {

            final bool isSelected = _selectedLevel == level;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: ActionChip(
                label: Text(
                  level,
                  style: TextStyle(
                     color: isSelected 
                     ? Theme.of(context).colorScheme.onSecondary 
                     : Theme.of(context).textTheme.bodyMedium?.color // ! Handle Text Color based on theme
                  ),
                ),

                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),

                labelPadding: const EdgeInsets.symmetric(
                  horizontal: 2,
                ),

                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,

                backgroundColor: isSelected ? Theme.of(context).colorScheme.secondary : Colors.transparent,

                onPressed: () {
                  setState(() {
                    _selectedLevel = level;
                  });

                  _filterLogs(context, level == 'ALL' ? '' : level);
                },
              ),
            );
          }
        ).toList(),
      ),
    );
  }
}
