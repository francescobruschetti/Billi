import 'package:Billy/constants.dart';
import 'package:Billy/pages/prove/button_group_prove_page.dart';
import 'package:Billy/pages/settings/logs_page.dart';
import 'package:Billy/pages/prove/multilanguage_prove_page.dart';
import 'package:Billy/pages/prove/segment/segment_page_prove.dart';
import 'package:Billy/pages/prove/tab_controller_prove_page.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class UIProvePage extends StatefulWidget {
  const UIProvePage({super.key});

  @override
  State<UIProvePage> createState() => _UIProvePageState();
}

class _UIProvePageState extends State<UIProvePage> {
  final Logger log = Logger('UIProvePage');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prove UI')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [           
            _buildMainGroup(context),

            // const SizedBox(height: AppConstants.mediumSizedBoxHeight),
            // const Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            //   child: Align(
            //     alignment: Alignment.centerLeft,
            //     child: Text(
            //       'Account',
            //       style: TextStyle(fontSize: AppConstants.textSize, fontWeight: FontWeight.bold, color: Colors.grey),
            //     ),
            //   ),
            // ),
            //
            // const SizedBox(height: AppConstants.mediumSizedBoxHeight),
            // Card(
            //   margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            //   child: Column(
            //     children: [
            //       _buildListTile(
            //         icon: Icon(Icons.heart_broken_rounded, color: Colors.orange[700]), 
            //         title: 'Elimina account',                    
            //         // TODO: add onTap to delete account
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainGroup(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        children: [
          _buildListTile(
            icon: Icon(Icons.language, color: Colors.orange[700]),
            title: 'Lingua', 
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MultiLinguaProvePage())),
          ),
          
          const Divider(height: 1),
          _buildListTile(
            icon: Icon(Icons.share, color: Colors.orange[700]), 
            title: 'TabController',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TabControllerProvePage())),
          ),
          
          const Divider(height: 1),
          _buildListTile(
            icon: Icon(Icons.group, color: Colors.orange[700]), 
            title: 'ButtonGroup',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ButtonGroupProvePage())),
          ),
          
          const Divider(height: 1),
           _buildListTile(
            icon: Icon(Icons.swipe, color: Colors.orange[700]), 
            title: 'Segment Control',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SegmentPageProve())),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({ required Icon icon, required String title, String? subtitle, VoidCallback? onTap}) {
    return ListTile(
      leading: icon,
      enabled: onTap != null,
      title: Row(
        children: [
          Text(title),
          const Spacer(),
          if (subtitle != null) Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(width: AppConstants.mediumSizedBoxWidth),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
      onTap: onTap
    );
  }
}