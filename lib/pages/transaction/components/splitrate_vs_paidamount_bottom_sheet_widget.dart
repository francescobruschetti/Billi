import 'package:Billy/models/group_expense_split_response_model.dart';
import 'package:Billy/pages/transaction/components/segment_control_page.dart';
import 'package:Billy/providers/ui_provider.dart';
import 'package:Billy/widgets/components/app_bottom_sheet.dart';
import 'package:Billy/widgets/components/custom_button_widget.dart';
import 'package:Billy/widgets/components/custom_validated_textfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



class SplitrateVsPaidamountBottomSheetWidget extends ConsumerStatefulWidget {
  final String? title;
  const SplitrateVsPaidamountBottomSheetWidget({super.key, this.title});

  @override
  ConsumerState<SplitrateVsPaidamountBottomSheetWidget> createState() => _SplitrateVsPaidamountBottomSheetWidgetState();
}

class _SplitrateVsPaidamountBottomSheetWidgetState extends ConsumerState<SplitrateVsPaidamountBottomSheetWidget> {
  static final ScrollController _verticalController = ScrollController();
  late final PageController _controller;

  late TextEditingController _priceController;
  late TextEditingController _paidAmountController;
  late TextEditingController _splitRateController;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _priceController = TextEditingController(text: '');
    _paidAmountController = TextEditingController();
    _splitRateController = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _priceController.removeListener(_onFieldChanged);
    _paidAmountController.removeListener(_onFieldChanged);
    _splitRateController.removeListener(_onFieldChanged);
    
    _priceController.dispose();
    _paidAmountController.dispose();
    _splitRateController.dispose();
    super.dispose();
  }

  double _formatPriceInput() {
    String text = _priceController.text;
    text = text.replaceAll(',', '.');
    _priceController.value = _priceController.value.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    return double.tryParse(text) ?? 0.0;
  }

  void _handleSplitRateValue(FilterSelection value) {
    ref.read(filterProvider.notifier).state = value;
  }

  void _onFieldChanged() {
    // TODO: 
    // setState(() {
    //   if (widget.transactionType == TransactionTypeEnum.EXPENSE) {
    //     _isSaveEnabled = (_selectedGroup != null && (_paidAmountController.text.isNotEmpty || _selectedSplitRateValue != null) && _priceController.text.isNotEmpty);
    //   }
    //   else {
    //     _isSaveEnabled = (_selectedGroup != null && _priceController.text.isNotEmpty);
    //   }
    // });
  }

  void _onTabChanged(int index) {
    ref.read(splitRateAndPaidAmountTabProvider.notifier).state = index;

    if (mounted) {
      _controller.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPageChanged(int index) {
    ref.read(splitRateAndPaidAmountTabProvider.notifier).state = index;
  }

  // void _handleThemeChange(BuildContext context, int index) {
  //   Navigator.of(context).pop(ThemeEnum.values[index]);
  // }

  void _save() {
    GroupExpenseSplitResponseModel response = GroupExpenseSplitResponseModel(
      filterSelected: ref.read(filterProvider.notifier).state,
      customPercentage: ref.read(filterProvider.notifier).state == FilterSelection.customPercentage ? int.tryParse(_splitRateController.text) : null,
      customFixedValue: ref.read(filterProvider.notifier).state == FilterSelection.customFixed ? int.tryParse(_splitRateController.text) : null,
      fixedAmount: ref.read(filterProvider.notifier).state == FilterSelection.fixedAmount ? _formatPriceInput() : null,
    );

    Navigator.of(context).pop(response);
  }

  @override
  Widget build(BuildContext context) {
    final int tabSelectedIndex = ref.watch(splitRateAndPaidAmountTabProvider);
    final FilterSelection? filterSelected = ref.watch(filterProvider);

    return AppBottomSheet(
      title: widget.title,
      initialSize: 0.9,
      minSize: 0.5,
      maxSize: 1.0,
      child: Scrollbar(
        controller: _verticalController,
        thumbVisibility: true,
        child: Scrollbar(
          notificationPredicate: (notif) => notif.metrics.axis == Axis.horizontal,
          child: SingleChildScrollView(
            controller: _verticalController,
            scrollDirection: Axis.vertical,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Pass filterSelected to _buildSegmentController
                return _buildSegmentController(tabSelectedIndex, filterSelected: filterSelected);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentController(int tabSelectedIndex, {required FilterSelection? filterSelected}) {
    return Column(
      children: [
        // Segmented control
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedControl(
            selectedIndex: tabSelectedIndex,
            onChanged: _onTabChanged,
          ),
        ),

        // PageView
        SizedBox(
          height: 400, // TODO: da sistamre
          child: PageView(
            controller: _controller,
            onPageChanged: _onPageChanged,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                child: _buildSplitRateComponents(filterSelected)
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 16, right: 16), 
                child: _buildFixedRateComponents(filterSelected)
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFixedRateComponents(FilterSelection? filterSelected) {
    return Column(
      children: [
        CustomValidatedTextField(
          controller: _paidAmountController,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*[.,]?[0-9]*$')),
          ],
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          labelText: 'Quota pagata',
          onChanged: (value) => _formatPriceInput(),
          prefixIcon: Icon(Icons.euro, size: 24),
        ),

        const SizedBox(height: 8),
        CustomButtonWidget(
          onPressed: filterSelected != null ? _save : null,
          text: 'Salva',
        )
      ],
    );
  }

  // v3
  Widget _buildSplitRateComponents(FilterSelection? filterSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text('Quanto paghi?', style: const TextStyle(fontWeight: FontWeight.bold)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: filterSelected == FilterSelection.oneQuarter ? BorderSide(color: Theme.of(context).colorScheme.secondary) : BorderSide.none, // TODO (_selectedSplitRateValueButton == SplitRateModeEnum.ONE_QUARTER ? BorderSide(color: Theme.of(context).colorScheme.secondary) : BorderSide.none),
                    ),
                    backgroundColor: filterSelected == FilterSelection.oneQuarter ? Theme.of(context).colorScheme.secondary : Colors.grey.shade200,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  ),
                  onPressed: () => _handleSplitRateValue(FilterSelection.oneQuarter),
                  child: const Text('25%'),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: filterSelected == FilterSelection.half ? BorderSide(color: Theme.of(context).colorScheme.secondary) : BorderSide.none, // TODO (_selectedSplitRateValueButton == SplitRateModeEnum.ONE_QUARTER ? BorderSide(color: Theme.of(context).colorScheme.secondary) : BorderSide.none),
                    ),
                    backgroundColor: filterSelected == FilterSelection.half ? Theme.of(context).colorScheme.secondary : Colors.grey.shade200,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  ),
                  onPressed: () => _handleSplitRateValue(FilterSelection.half),
                  child: const Text('50%'),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: filterSelected == FilterSelection.threeQuarters ? BorderSide(color: Theme.of(context).colorScheme.secondary) : BorderSide.none, // TODO (_selectedSplitRateValueButton == SplitRateModeEnum.ONE_QUARTER ? BorderSide(color: Theme.of(context).colorScheme.secondary) : BorderSide.none),
                    ),
                    backgroundColor: filterSelected == FilterSelection.threeQuarters ? Theme.of(context).colorScheme.secondary : Colors.grey.shade200,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  ),
                  onPressed: () => _handleSplitRateValue(FilterSelection.threeQuarters),
                  child: const Text('75%'),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: filterSelected == FilterSelection.evenly ? BorderSide(color: Theme.of(context).colorScheme.secondary) : BorderSide.none, // TODO (_selectedSplitRateValueButton == SplitRateModeEnum.ONE_QUARTER ? BorderSide(color: Theme.of(context).colorScheme.secondary) : BorderSide.none),
                    ),
                    backgroundColor: filterSelected == FilterSelection.evenly ? Theme.of(context).colorScheme.secondary : Colors.grey.shade200,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  ),
                  onPressed: () => _handleSplitRateValue(FilterSelection.evenly),
                  child: const Text('Evenly'),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: filterSelected == FilterSelection.zero ? BorderSide(color: Theme.of(context).colorScheme.secondary) : BorderSide.none, // TODO (_selectedSplitRateValueButton == SplitRateModeEnum.ONE_QUARTER ? BorderSide(color: Theme.of(context).colorScheme.secondary) : BorderSide.none),
                    ),
                    backgroundColor: filterSelected == FilterSelection.zero ? Theme.of(context).colorScheme.secondary : Colors.grey.shade200,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  ),
                  onPressed: () => _handleSplitRateValue(FilterSelection.zero),
                  child: const Text('Hai anticipato tu'),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: '%',
                    contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (value) {
                    int? parsedValue = int.tryParse(value);
                    if (parsedValue != null) {
                      _handleSplitRateValue(FilterSelection.customPercentage);
                    }
                  },
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),
        Text('Per quanti paghi?', style: const TextStyle(fontWeight: FontWeight.bold)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: filterSelected == FilterSelection.fixed1 ? BorderSide(color: Theme.of(context).colorScheme.secondary) : BorderSide.none, // TODO (_selectedSplitRateValueButton == SplitRateModeEnum.ONE_QUARTER ? BorderSide(color: Theme.of(context).colorScheme.secondary) : BorderSide.none),
                    ),
                    backgroundColor: filterSelected == FilterSelection.fixed1 ? Theme.of(context).colorScheme.secondary : Colors.grey.shade200,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  ),
                  onPressed: () => _handleSplitRateValue(FilterSelection.fixed1),
                  child: const Text('1'),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: filterSelected == FilterSelection.fixed2 ? BorderSide(color: Theme.of(context).colorScheme.secondary) : BorderSide.none, // TODO (_selectedSplitRateValueButton == SplitRateModeEnum.ONE_QUARTER ? BorderSide(color: Theme.of(context).colorScheme.secondary) : BorderSide.none),
                    ),
                    backgroundColor: filterSelected == FilterSelection.fixed2 ? Theme.of(context).colorScheme.secondary : Colors.grey.shade200,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  ),
                  onPressed: () => _handleSplitRateValue(FilterSelection.fixed2),
                  child: const Text('2'),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: filterSelected == FilterSelection.fixed3 ? BorderSide(color: Theme.of(context).colorScheme.secondary) : BorderSide.none, // TODO (_selectedSplitRateValueButton == SplitRateModeEnum.ONE_QUARTER ? BorderSide(color: Theme.of(context).colorScheme.secondary) : BorderSide.none),
                    ),
                    backgroundColor: filterSelected == FilterSelection.fixed3 ? Theme.of(context).colorScheme.secondary : Colors.grey.shade200,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  ),
                  onPressed: () => _handleSplitRateValue(FilterSelection.fixed3),
                  child: const Text('3'),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: filterSelected == FilterSelection.fixed4 ? BorderSide(color: Theme.of(context).colorScheme.secondary) : BorderSide.none, // TODO (_selectedSplitRateValueButton == SplitRateModeEnum.ONE_QUARTER ? BorderSide(color: Theme.of(context).colorScheme.secondary) : BorderSide.none),
                    ),
                    backgroundColor: filterSelected == FilterSelection.fixed4 ? Theme.of(context).colorScheme.secondary : Colors.grey.shade200,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  ),
                  onPressed: () => _handleSplitRateValue(FilterSelection.fixed4),
                  child: const Text('4'),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Altro',
                    contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (value) {
                    int? parsedValue = int.tryParse(value);
                    if (parsedValue != null) {
                      _handleSplitRateValue(FilterSelection.customFixed);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      
        const SizedBox(height: 8),
        CustomButtonWidget(
          onPressed: filterSelected != null ? _save : null,
          text: 'Salva',
        )
      ]
    );
  }

  // old version v1:
  /*Widget _buildSplitRateComponents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text('Quanto paghi?', style: const TextStyle(fontWeight: FontWeight.bold)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide.none // TODO (_selectedSplitRateValueButton == SplitRateModeEnum.ONE_QUARTER ? BorderSide(color: Theme.of(context).colorScheme.secondary) : BorderSide.none),
                    ),
                    backgroundColor: Colors.grey.shade200, // TODO: (_selectedSplitRateValueButton == SplitRateModeEnum.ONE_QUARTER ? Theme.of(context).colorScheme.secondary : Colors.grey.shade200),
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  ),
                  onPressed: () => {}, // TODO: _handleSplitRateValue(SplitRateModeEnum.ONE_QUARTER),
                  child: const Text('25%'),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide.none // TODO (_selectedSplitRateValueButton == SplitRateModeEnum.HALF ? BorderSide(color: Theme.of(context).colorScheme.secondary) : BorderSide.none),
                    ),
                    backgroundColor: Colors.grey.shade200, // TODO: (_selectedSplitRateValueButton == SplitRateModeEnum.HALF ? Theme.of(context).colorScheme.secondary : Colors.grey.shade200),
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  ),
                  onPressed: () => {}, // TODO: _handleSplitRateValue(SplitRateModeEnum.HALF),
                  child: const Text('50%'),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide.none // TODO (_selectedSplitRateValueButton == SplitRateModeEnum.THREE_QUARTERS ? BorderSide(color: Theme.of(context).colorScheme.secondary) : BorderSide.none),
                    ),
                    backgroundColor: Colors.grey.shade200, // TODO: (_selectedSplitRateValueButton == SplitRateModeEnum.THREE_QUARTERS ? Theme.of(context).colorScheme.secondary : Colors.grey.shade200),
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  ),
                  onPressed: () => {}, // TODO: _handleSplitRateValue(SplitRateModeEnum.THREE_QUARTERS),
                  child: const Text('75%'),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide.none // TODO (_selectedSplitRateValueButton == SplitRateModeEnum.EQUALLY ? BorderSide(color: Theme.of(context).colorScheme.secondary) : BorderSide.none),
                    ),
                    backgroundColor: Colors.grey.shade200, // TODO: (_selectedSplitRateValueButton == SplitRateModeEnum.EQUALLY ? Theme.of(context).colorScheme.secondary : Colors.grey.shade200),
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  ),
                  onPressed: () => {}, // TODO: _handleSplitRateValue(SplitRateModeEnum.EQUALLY),
                  child: const Text('Equally'),
                ),
              ),
            ),
            Expanded(
              flex: 2, // Bottone più largo per il 100%
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide.none // TODO (_selectedSplitRateValueButton == SplitRateModeEnum.ZERO ? BorderSide(color: Theme.of(context).colorScheme.secondary) : BorderSide.none),
                    ),
                    backgroundColor: Colors.grey.shade200, // TODO: (_selectedSplitRateValueButton == SplitRateModeEnum.ZERO ? Theme.of(context).colorScheme.secondary : Colors.grey.shade200),
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
                  ),
                  onPressed: () => {}, // TODO: _handleSplitRateValue(SplitRateModeEnum.ZERO),
                  child: const Text('Hai anticipato tu'),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: '%',
                    contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [ FilteringTextInputFormatter.digitsOnly, ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),
        Text('Per quanti paghi?', style: const TextStyle(fontWeight: FontWeight.bold)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide.none // TODO (_selectedSplitRateValueButton == SplitRateModeEnum.FIXED_1 ? BorderSide(color: Theme.of(context).colorScheme.secondary) : BorderSide.none),
                    ),
                    backgroundColor: Colors.grey.shade200, // TODO: (_selectedSplitRateValueButton == SplitRateModeEnum.FIXED_1 ? Theme.of(context).colorScheme.secondary : Colors.grey.shade200),
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  ),
                  onPressed: () => {}, // TODO: _handleSplitRateValue(SplitRateModeEnum.FIXED_1),
                  child: const Text('1'),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide.none // TODO (_selectedSplitRateValueButton == SplitRateModeEnum.FIXED_2 ? BorderSide(color: Theme.of(context).colorScheme.secondary) : BorderSide.none),
                    ),
                    backgroundColor: Colors.grey.shade200, // TODO: (_selectedSplitRateValueButton == SplitRateModeEnum.FIXED_2 ? Theme.of(context).colorScheme.secondary : Colors.grey.shade200),
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  ),
                  onPressed: () => {}, // TODO: _handleSplitRateValue(SplitRateModeEnum.FIXED_2),
                  child: const Text('2'),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide.none // TODO (_selectedSplitRateValueButton == SplitRateModeEnum.FIXED_3 ? BorderSide(color: Theme.of(context).colorScheme.secondary) : BorderSide.none),
                    ),
                    backgroundColor: Colors.grey.shade200, // TODO: (_selectedSplitRateValueButton == SplitRateModeEnum.FIXED_3 ? Theme.of(context).colorScheme.secondary : Colors.grey.shade200),
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  ),
                  onPressed: () => {}, // TODO: _handleSplitRateValue(SplitRateModeEnum.FIXED_3),
                  child: const Text('3'),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide.none // TODO (_selectedSplitRateValueButton == SplitRateModeEnum.FIXED_4 ? BorderSide(color: Theme.of(context).colorScheme.secondary) : BorderSide.none),
                    ),
                    backgroundColor: Colors.grey.shade200, // TODO: (_selectedSplitRateValueButton == SplitRateModeEnum.FIXED_4 ? Theme.of(context).colorScheme.secondary : Colors.grey.shade200),
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  ),
                  onPressed: () => {}, // TODO: _handleSplitRateValue(SplitRateModeEnum.FIXED_4),
                  child: const Text('4'),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Altro',
                    contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
              ),
            ),
          ],
        ),
      ]
    );
  }*/
  
}