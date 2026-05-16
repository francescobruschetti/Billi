import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class LogsProvePage extends StatefulWidget {
  const LogsProvePage({super.key});

  @override
  State<LogsProvePage> createState() => _LogsProvePageState();

  static List<String> logs = [];
  static void insertLog(String s) {
    logs.insert(0, s);
  }
}

class _LogsProvePageState extends State<LogsProvePage> {
  final Logger log = Logger('LogsProvePage');
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Prova Logs')),
      body: Center(
        child: ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: LogsProvePage.logs.length, // +1 per il loader in fondo
          itemBuilder: (context, index) {
            // Mostra il loader in fondo se stiamo caricando più elementi
            return Card(
              color: Colors.transparent,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(LogsProvePage.logs[index]),
            );
          }
        ),
      ),
    );
  }
}