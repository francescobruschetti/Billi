import 'package:Billy/constants.dart';
import 'package:Billy/widgets/components/app_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InvitationLinkBottomSheetWidget extends StatefulWidget {
  final String title;
  final String subTitle;
  final String link;

  const InvitationLinkBottomSheetWidget({
    super.key, required this.title, required this.subTitle, required this.link
  });

  @override
  State<InvitationLinkBottomSheetWidget> createState() => _InvitationLinkBottomSheetWidgetState();
}

class _InvitationLinkBottomSheetWidgetState extends State<InvitationLinkBottomSheetWidget> {
  static final ScrollController _verticalController = ScrollController();

  String get title => widget.title;
  String get subTitle => widget.subTitle;
  String get link => widget.link;

  bool _showInfo = false;
  String _infoMessage = '';

  @override
  void dispose() {
    _verticalController.dispose();
    super.dispose();
  }

  void _showPopupMessage(String message) {
    setState(() {
      _showInfo = true;
      _infoMessage = message;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _showInfo = false;
        _infoMessage = '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: title,
      initialSize: 0.5,
      minSize: 0.25,
      maxSize: 0.51,

      child: SingleChildScrollView(
        controller: _verticalController,
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSubTitle(context),

            const SizedBox(height: AppConstants.mediumSizedBoxHeight),
            _buildInviteLinkText(context),

            if (_showInfo) ...[
              const SizedBox(height: AppConstants.mediumSizedBoxHeight),
              _buildInfoMessage(context),
            ],

            const SizedBox(height: AppConstants.mediumSizedBoxHeight),
            _buildActionButtonRow(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) 
  {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.only(bottom: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppConstants.defaultButtonBorderColor, // borderColor ?? Theme.of(context).colorScheme.primary,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(icon, color: Theme.of(context).colorScheme.primary),
              onPressed: onPressed,
            ),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtonRow(BuildContext context) {
    return Row(
      children: [
        _buildActionsButton(
          context: context,
          icon: Icons.copy,
          label: 'Copia link',
          onPressed: () {
            Clipboard.setData(ClipboardData(text: link));
            _showPopupMessage('Link copiato negli appunti');
          },
        ),
        _buildActionsButton(
          context: context,
          icon: Icons.ios_share,
          label: 'Condividi',
          onPressed: () => _showPopupMessage('Funzione di condivisione non ancora implementata'), // TODO: implementare condivisione link
        ),
        _buildActionsButton(
          context: context,
          icon: Icons.refresh,
          label: 'Rigenera link',
          onPressed: () => _showPopupMessage('Funzione di rigenerazione link non ancora implementata'), // TODO: implementare rigenerazione link
        ),
      ],
    );
          
  }

  Widget _buildInviteLinkText(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        border: Border.all(
          color: AppConstants.defaultButtonBorderColor, // borderColor ?? Theme.of(context).colorScheme.primary,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SelectableText(link, 
        style: TextStyle(
          fontSize: AppConstants.subtitleTextSize, 
          color: Theme.of(context).colorScheme.onSecondary,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold,
        ), 
        textAlign: TextAlign.center
      )
    );
  }

  Widget _buildInfoMessage(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
      child: Text(_infoMessage, textAlign: TextAlign.center, style: TextStyle(fontSize: AppConstants.textSize, color: Theme.of(context).colorScheme.onSecondaryContainer)),
    );
  }

  Widget _buildSubTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Text(
        subTitle, 
        textAlign: TextAlign.center, 
        style: TextStyle(
          fontSize: AppConstants.textSize, 
        ),
      ),
    );
  }
}