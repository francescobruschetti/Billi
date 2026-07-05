import 'package:Billy/constants.dart';
import 'package:Billy/extentions/datetime_extention.dart';
import 'package:Billy/local/database/app_database.dart';
import 'package:Billy/pages/settings/api_token_details_page.dart';
import 'package:Billy/pages/settings/components/api_token_bottom_sheet_widget.dart';
import 'package:Billy/providers/local-database/api_token_provider.dart';
import 'package:Billy/services/api_token_service.dart';
import 'package:Billy/utils/generic_util.dart';
import 'package:Billy/widgets/components/custom_button_widget.dart';
import 'package:Billy/widgets/components/custom_icon_widget.dart';
import 'package:Billy/widgets/components/floating_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

class ApiTokenPage extends ConsumerStatefulWidget {
  const ApiTokenPage({super.key});

  @override
  ConsumerState<ApiTokenPage> createState() => _ApiTokenPageState();
}

class _ApiTokenPageState extends ConsumerState<ApiTokenPage> 
{
  final Logger log = Logger('ApiTokenPage');
  final ScrollController _scrollController = ScrollController();
  final ApiTokenService _apiTokenService = ApiTokenService();
  
  late DateTime _lastRefreshTime = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  void _createEditToken() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ApiTokenDetailsPage()),
    );

    if (result != null) {
      await showModalBottomSheet<ApiTokenBottomSheetWidget>(
        context: context,
        isScrollControlled: true, // obbligatorio per DraggableScrollableSheet
        backgroundColor: Colors.transparent, // lascia gestire il colore al sheet
        builder: (BuildContext context) => ApiTokenBottomSheetWidget(
          title: 'Token di Accesso',
          subTitle: 'Il token generato ti permetterà di accedere all\'app senza inserire le credenziali.',
          token: result,
          warningMsg: 'Il token non sarà più visibile dopo la chiusura di questo pannello!',
        ),
      );
    }

    // Aggiorna la lista dei token dopo la creazione/modifica
    // await ref.read(apiTokenProvider.notifier).fetchAndSave();
    _apiTokenService.fetchApiTokens().then((tokens) {
      setState(() {
        _lastRefreshTime = DateTime.now();
      });
    });
  }

  Future<void> _refreshTokenList() async {
    await ref.read(apiTokenProvider.notifier).fetchAndSave();
    _lastRefreshTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final apiTokensState = ref.watch(apiTokenProvider);

    final isRefreshing = ref.watch(
      apiTokenProvider.select((_) => ref.read(apiTokenProvider.notifier).isRefreshing),
    );

    return apiTokensState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text("Errore durante il caricamento. Riprovare")), // TODO: migliorare gestione errori
      data: (apiTokens) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: _buildAppBar(),
          floatingActionButton: FloatingButtonWidget(
            onPressed: _createEditToken,
            iconButton: CustomIconWidget(
              assetPath: 'assets/images/icons/add.PNG',
              size: 24,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
          body: _buildBody(apiTokens, isRefreshing),
        );
      },
    );
  }
  
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Token di Accesso'),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 8),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh),
          tooltip: 'Aggiorna',
          onPressed: () => null, // TODO: implement refresh
        ),
        // TODO: implement filters?
        // IconButton(
        //   icon: CustomIconWidget(assetPath: 'assets/images/icons/settings.PNG', size: 24),
        //   tooltip: 'Impostazioni Gruppo',
        //   onPressed: () => null, 
        // ),
      ],
    );
  }

  Widget _buildApiTokensList(List<ApiTokenTableData> apiTokens) {
    return Expanded(
      child: apiTokens.isEmpty
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Nessun token di accesso trovato', 
                  style: TextStyle(fontSize: AppConstants.textSize)
                ),
                SizedBox(height: AppConstants.sizedBoxHeight),
                IntrinsicWidth( // Note Docs: Force button to take only the necessary width
                  child: CustomButtonWidget(
                    onPressed: _refreshTokenList, // Note Docs: non esegue direttamente _refreshTokenList() per evitare di chiamare la funzione al momento della build. Use () { _refreshTokenList(param1, param2); } or pass the function reference without parentheses.
                    text: 'Ricarica',
                    iconData: Icons.refresh,
                  ),
                )
              ]
            ),
          )
        : RefreshIndicator( // Pull from top to refresh
              onRefresh: _refreshTokenList,
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: apiTokens.length,
                itemBuilder: (context, index) {
                  return _buildApiTokenTile(apiTokens[index]);
                }
              ),
            ),
    );
  }

  Widget _buildApiTokenTile(ApiTokenTableData apiToken) {
    return ListTile(
      title: Text('Token: ${apiToken.name}'),
      subtitle: Text('Scadenza: ${apiToken.validUntil.toDateStr()}'),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () => null, // TODO: implement delete
      ),
    );
  }

  Widget _buildBody(List<ApiTokenTableData> apiTokens, bool isRefreshing) {
    return Stack(
      children: [
        Text('Ultimo aggiornamento: ${apiTokens.length}'),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: AppConstants.mediumSizedBoxHeight),
            GenericUtil.buildLoadingOverlayCircularIndicator(isRefreshing, color: Theme.of(context).colorScheme.secondary),

            _buildApiTokensList(apiTokens),
          ],
        ),
      ],
    );
  }
}