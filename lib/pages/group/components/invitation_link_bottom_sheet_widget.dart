import 'package:Billy/constants.dart';
import 'package:Billy/models/group_participant_summary_model.dart';
import 'package:Billy/utils/generic_util.dart';
import 'package:Billy/widgets/components/app_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

class InvitationLinkBottomSheetWidget extends AppBottomSheet {
  static final ScrollController _verticalController = ScrollController();

  final String title;
  final String subTitle;
  final String link;

  InvitationLinkBottomSheetWidget({
    super.key, required this.title, required this.subTitle, required this.link
  }) : super( title: title, child: Container());


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

            const SizedBox(height: 8),
            _buildInviteLinkText(context),

            const SizedBox(height: 8),
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
  }) {
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
            
            // workaround con delay per evitare che il bottom sheet venga chiuso prima che venga mostrato lo snackbar
            final rootContext = Navigator.of(context).context; // Salva PRIMA del pop!
            Navigator.of(context).pop();
            Future.delayed(const Duration(milliseconds: 200), () {
              if (rootContext.mounted) {
                GenericUtil.showSnackbar(rootContext, 'Link copiato negli appunti');
              }
            });
          },
        ),
        _buildActionsButton(
          context: context,
          icon: Icons.ios_share,
          label: 'Condividi',
          onPressed: () => GenericUtil.showSnackbar(context, 'Funzione di condivisione non ancora implementata'), // TODO: implementare condivisione link
        ),
        _buildActionsButton(
          context: context,
          icon: Icons.refresh,
          label: 'Rigenera link',
          onPressed: () => GenericUtil.showSnackbar(context, 'Funzione di rigenerazione link non ancora implementata'), // TODO: implementare rigenerazione link
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
          fontSize: 24, 
          color: Theme.of(context).colorScheme.onSecondary,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold,
        ), 
        textAlign: TextAlign.center
      )
    );
  }

  Widget _buildSubTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Text(
        subTitle, 
        textAlign: TextAlign.center, 
        style: TextStyle(
          fontSize: 14, 
        ),
      ),
    );
  }
}