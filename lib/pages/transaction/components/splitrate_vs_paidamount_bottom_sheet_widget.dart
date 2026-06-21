import 'package:Billy/constants.dart';
import 'package:Billy/enums/split_rate_mode_enum.dart';
import 'package:Billy/models/group/group_expense_split_response_model.dart';
import 'package:Billy/pages/transaction/components/segment_control_page.dart';
import 'package:Billy/providers/ui_provider.dart';
import 'package:Billy/widgets/components/app_bottom_sheet.dart';
import 'package:Billy/widgets/components/custom_button_widget.dart';
import 'package:Billy/widgets/components/custom_validated_textfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';


class SplitrateVsPaidamountBottomSheetWidget extends ConsumerStatefulWidget {
  final SplitRateModeEnum? splitRateModeEnum;
  final GroupExpenseSplitResponseModel? groupExpenseSplitResponseModel;
  const SplitrateVsPaidamountBottomSheetWidget({super.key, this.splitRateModeEnum, this.groupExpenseSplitResponseModel});

  @override
  ConsumerState<SplitrateVsPaidamountBottomSheetWidget> createState() => _SplitrateVsPaidamountBottomSheetWidgetState();
}

class _SplitrateVsPaidamountBottomSheetWidgetState extends ConsumerState<SplitrateVsPaidamountBottomSheetWidget> {
  final Logger log = Logger('SplitrateVsPaidamountBottomSheetWidget');
  final ScrollController _verticalController = ScrollController();
  late final PageController _controller;

  late TextEditingController _customPercentageController;
  late TextEditingController _customFixedController;
  late TextEditingController _paidAmountController;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.groupExpenseSplitResponseModel?.tabSelectedIndex ?? 0);
    _customPercentageController = TextEditingController(text: '');
    _customFixedController = TextEditingController(text: '');
    _paidAmountController = TextEditingController(text: '');

    _customPercentageController.addListener(() => _onFieldChanged(SplitRateModeEnum.CUSTOM_PERCENTAGE, textValue: _customPercentageController.text));
    _customFixedController.addListener(() => _onFieldChanged(SplitRateModeEnum.CUSTOM_FIXED, textValue: _customFixedController.text));
    _paidAmountController.addListener(() => _onFieldChanged(SplitRateModeEnum.FIXED_AMOUNT, textValue: _paidAmountController.text));

    if (widget.groupExpenseSplitResponseModel != null) {
      Future.microtask(() {
        ref.read(splitRateModeProvider.notifier).state = widget.groupExpenseSplitResponseModel?.splitRateModeEnum;
        ref.read(splitRateAndPaidAmountTabProvider.notifier).state = widget.groupExpenseSplitResponseModel?.tabSelectedIndex ?? 0;
        log.info('Initialized splitRateModeProvider with ${widget.groupExpenseSplitResponseModel?.splitRateModeEnum} and splitRateAndPaidAmountTabProvider with ${widget.groupExpenseSplitResponseModel?.tabSelectedIndex}');

        _customPercentageController.text = widget.groupExpenseSplitResponseModel?.customPercentage?.toString() ?? '';
        _customFixedController.text = widget.groupExpenseSplitResponseModel?.customFixedValue?.toString() ?? '';
        _paidAmountController.text = widget.groupExpenseSplitResponseModel?.fixedAmount?.toString() ?? '';
      });
    }
    else if (widget.splitRateModeEnum != null) {
      Future.microtask(() {
        ref.read(splitRateModeProvider.notifier).state = widget.splitRateModeEnum!;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _customPercentageController.removeListener(() => _onFieldChanged(SplitRateModeEnum.CUSTOM_PERCENTAGE, textValue: _customPercentageController.text));
    _customFixedController.removeListener(() => _onFieldChanged(SplitRateModeEnum.CUSTOM_FIXED, textValue: _customFixedController.text));
    _paidAmountController.removeListener(() => _onFieldChanged(SplitRateModeEnum.FIXED_AMOUNT, textValue: _paidAmountController.text));
    
    _customPercentageController.dispose();
    _customFixedController.dispose();
    _paidAmountController.dispose();
    super.dispose();
  }

  double _formatPriceInput(String value) {
    value = value.replaceAll(',', '.');
    _paidAmountController.value = _paidAmountController.value.copyWith(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    return double.tryParse(value) ?? 0.0;
  }

  void _handleSplitRateValue(SplitRateModeEnum value) {
    ref.read(splitRateModeProvider.notifier).state = value;
  }
  
  void _onFieldChanged(SplitRateModeEnum value, {String? textValue}) {
    if (textValue != null && textValue.isNotEmpty) {
      _handleSplitRateValue(value);

      setState(() {
        switch (value) {
          case SplitRateModeEnum.CUSTOM_PERCENTAGE:
            _customFixedController.text = '';
            _paidAmountController.text = '';
            break;
          case SplitRateModeEnum.CUSTOM_FIXED:
            _customPercentageController.text = '';
            _paidAmountController.text = '';
            break;
          case SplitRateModeEnum.FIXED_AMOUNT:
            _customPercentageController.text = '';
            _customFixedController.text = '';
            break;
          default:
            break;
        }
      });
    }
  }

  void _onSplitRateChanged(SplitRateModeEnum value) {
    _handleSplitRateValue(value);

    _customFixedController.text = '';
    _customPercentageController.text = '';
    _paidAmountController.text = '';
  }

  void _onTabChanged(int index) {
    ref.read(splitRateAndPaidAmountTabProvider.notifier).setTab(index);

    if (mounted) {
      _controller.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _save() {

    int tabIndexResponse;
    if (widget.groupExpenseSplitResponseModel?.splitRateModeEnum != ref.read(splitRateModeProvider.notifier).state!) {
      tabIndexResponse = ref.read(splitRateAndPaidAmountTabProvider.notifier).state;
    }
    else {
      tabIndexResponse = widget.groupExpenseSplitResponseModel?.tabSelectedIndex ?? 0;
    }

    GroupExpenseSplitResponseModel response = GroupExpenseSplitResponseModel(
      splitRateModeEnum: ref.read(splitRateModeProvider.notifier).state!,
      customPercentage: _customPercentageController.text.isNotEmpty ? int.tryParse(_customPercentageController.text) : null,
      customFixedValue: _customFixedController.text.isNotEmpty ? int.tryParse(_customFixedController.text) : null,
      fixedAmount: _paidAmountController.text.isNotEmpty ? _formatPriceInput(_paidAmountController.text) : null,
      tabSelectedIndex: tabIndexResponse
    );

    Navigator.of(context).pop(response);
  }

  @override
  Widget build(BuildContext context) {
    final int tabSelectedIndex = ref.watch(splitRateAndPaidAmountTabProvider);
    final SplitRateModeEnum? filterSelected = ref.watch(splitRateModeProvider);

    return AppBottomSheet(
      initialSize: 0.9,
      minSize: 0.5,
      maxSize: 1.0,
      child: SingleChildScrollView(
        controller: _verticalController,
        scrollDirection: Axis.vertical,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Pass splitRateModeEnum to _buildSegmentController
            return _buildSegmentController(tabSelectedIndex, splitRateModeEnum: filterSelected);
          },
        ),
      ),
    );
  }

  Widget _buildSegmentController(int tabSelectedIndex, {required SplitRateModeEnum? splitRateModeEnum}) {
    return Column(
      children: [
        // Segmented control
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedControl(
            selectedIndex: tabSelectedIndex,
            onChanged: _onTabChanged,
            segments: const [
              MapEntry('Dividi spesa', Icons.pie_chart),
              MapEntry('Specifica quota', Icons.edit),
            ],
          ),
        ),

        // PageView
        SizedBox(
          height: 400, // TODO: da sistemare
          child: PageView(
            controller: _controller,
            onPageChanged: _onTabChanged,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                child: _buildSplitRateComponents(splitRateModeEnum)
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 16, right: 16), 
                child: _buildFixedRateComponents(splitRateModeEnum)
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFixedRateComponents(SplitRateModeEnum? splitRateModeEnum) {
    return Column(
      children: [
        CustomValidatedTextField(
          controller: _paidAmountController,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*[.,]?[0-9]*$')),
          ],
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          labelText: 'Quota pagata',
          onChanged: (value) => _formatPriceInput(value),
          prefixIcon: Icon(Icons.euro, size: 24),
        ),

        const SizedBox(height: AppConstants.mediumSizedBoxHeight),
        CustomButtonWidget(
          onPressed: _save,
          text: 'Salva',
          isEnabled: splitRateModeEnum != null,
        )
      ],
    );
  }

  Widget _buildSplitRateComponents(SplitRateModeEnum? splitRateModeEnum) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppConstants.mediumSizedBoxHeight),
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
                      side: splitRateModeEnum == SplitRateModeEnum.ONE_QUARTER ? BorderSide(color: Theme.of(context).colorScheme.secondaryContainer) : BorderSide.none, 
                    ),
                    backgroundColor: splitRateModeEnum == SplitRateModeEnum.ONE_QUARTER ? Theme.of(context).colorScheme.secondaryContainer : AppConstants.defaultButtonColor,
                    foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  ),
                  onPressed: () => _onSplitRateChanged(SplitRateModeEnum.ONE_QUARTER),
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
                      side: splitRateModeEnum == SplitRateModeEnum.HALF ? BorderSide(color: Theme.of(context).colorScheme.secondaryContainer) : BorderSide.none,
                    ),
                    backgroundColor: splitRateModeEnum == SplitRateModeEnum.HALF ? Theme.of(context).colorScheme.secondaryContainer : AppConstants.defaultButtonColor,
                    foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  ),
                  onPressed: () => _onSplitRateChanged(SplitRateModeEnum.HALF),
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
                      side: splitRateModeEnum == SplitRateModeEnum.THREE_QUARTERS ? BorderSide(color: Theme.of(context).colorScheme.secondaryContainer) : BorderSide.none,
                    ),
                    backgroundColor: splitRateModeEnum == SplitRateModeEnum.THREE_QUARTERS ? Theme.of(context).colorScheme.secondaryContainer : AppConstants.defaultButtonColor,
                    foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  ),
                  onPressed: () => _onSplitRateChanged(SplitRateModeEnum.THREE_QUARTERS),
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
                      side: splitRateModeEnum == SplitRateModeEnum.ZERO ? BorderSide(color: Theme.of(context).colorScheme.secondaryContainer) : BorderSide.none,
                    ),
                    backgroundColor: splitRateModeEnum == SplitRateModeEnum.ZERO ? Theme.of(context).colorScheme.secondaryContainer : AppConstants.defaultButtonColor,
                    foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  ),
                  onPressed: () => _onSplitRateChanged(SplitRateModeEnum.ZERO),
                  child: const Text('Hai anticipato tu'),
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
                      side: splitRateModeEnum == SplitRateModeEnum.EVENLY ? BorderSide(color: Theme.of(context).colorScheme.secondaryContainer) : BorderSide.none,
                    ),
                    backgroundColor: splitRateModeEnum == SplitRateModeEnum.EVENLY ? Theme.of(context).colorScheme.secondaryContainer : AppConstants.defaultButtonColor,
                    foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  ),
                  onPressed: () => _onSplitRateChanged(SplitRateModeEnum.EVENLY),
                  child: const Text('Evenly'),
                ),
              ),
            ),
            
            // disabled for now (not supported in summary algorithm)
            // Expanded(
            //   child: Container(
            //     margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
            //     child: CustomValidatedTextField(
            //       controller: _customPercentageController,
            //       inputFormatters: [
            //         FilteringTextInputFormatter.digitsOnly,
            //         TextInputFormatter.withFunction((oldValue, newValue) {
            //           final text = newValue.text;
            //           if (text.isEmpty) return newValue;
            //           final value = int.tryParse(text);
            //           if (value == null) return oldValue;
            //           if (value < 0 || value > 100) return oldValue;
            //           return newValue;
            //         }),
            //       ],
            //       keyboardType: const TextInputType.numberWithOptions(decimal: false),
            //       labelText: '%',
            //     ),
            //   ),
            // ),
          ],
        ),

        const SizedBox(height: AppConstants.mediumSizedBoxHeight),
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
                      side: splitRateModeEnum == SplitRateModeEnum.FIXED_1 ? BorderSide(color: Theme.of(context).colorScheme.secondaryContainer) : BorderSide.none,
                    ),
                    backgroundColor: splitRateModeEnum == SplitRateModeEnum.FIXED_1 ? Theme.of(context).colorScheme.secondaryContainer : AppConstants.defaultButtonColor,
                    foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  ),
                  onPressed: () => _onSplitRateChanged(SplitRateModeEnum.FIXED_1),
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
                      side: splitRateModeEnum == SplitRateModeEnum.FIXED_2 ? BorderSide(color: Theme.of(context).colorScheme.secondaryContainer) : BorderSide.none,
                    ),
                    backgroundColor: splitRateModeEnum == SplitRateModeEnum.FIXED_2 ? Theme.of(context).colorScheme.secondaryContainer : AppConstants.defaultButtonColor,
                    foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  ),
                  onPressed: () => _onSplitRateChanged(SplitRateModeEnum.FIXED_2),
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
                      side: splitRateModeEnum == SplitRateModeEnum.FIXED_3 ? BorderSide(color: Theme.of(context).colorScheme.secondaryContainer) : BorderSide.none,
                    ),
                    backgroundColor: splitRateModeEnum == SplitRateModeEnum.FIXED_3 ? Theme.of(context).colorScheme.secondaryContainer : AppConstants.defaultButtonColor,
                    foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  ),
                  onPressed: () => _onSplitRateChanged(SplitRateModeEnum.FIXED_3),
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
                      side: splitRateModeEnum == SplitRateModeEnum.FIXED_4 ? BorderSide(color: Theme.of(context).colorScheme.secondaryContainer) : BorderSide.none,
                    ),
                    backgroundColor: splitRateModeEnum == SplitRateModeEnum.FIXED_4 ? Theme.of(context).colorScheme.secondaryContainer : AppConstants.defaultButtonColor,
                    foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  ),
                  onPressed: () => _onSplitRateChanged(SplitRateModeEnum.FIXED_4),
                  child: const Text('4'),
                ),
              ),
            ),
            
            // // disabled for now (not supported in summary algorithm)
            // Expanded(
            //   child: Container(
            //     margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
            //     child: CustomValidatedTextField(
            //       controller: _customFixedController,
            //       inputFormatters: [
            //         FilteringTextInputFormatter.digitsOnly,
            //         TextInputFormatter.withFunction((oldValue, newValue) {
            //           final text = newValue.text;
            //           if (text.isEmpty) return newValue;
            //           final value = int.tryParse(text);
            //           if (value == null) return oldValue;
            //           if (value < 0 || value > 10) return oldValue;
            //           return newValue;
            //         }),
            //       ],
            //       keyboardType: const TextInputType.numberWithOptions(decimal: false),
            //       labelText: 'Altro',
            //     ),
            //   ),
            // ),
          ],
        ),
      
        const SizedBox(height: AppConstants.mediumSizedBoxHeight),
        CustomButtonWidget(
          onPressed: _save,
          text: 'Salva',
          isEnabled: splitRateModeEnum != null,
        )
      ]
    );
  }
}