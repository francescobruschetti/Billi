import 'package:Billy/constants.dart';
import 'package:Billy/pages/group/components/app_bottom_sheet.dart';
import 'package:Billy/providers/category_provider.dart';
import 'package:Billy/widgets/components/custom_validated_textfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

class CategoriesBottomSheetWidget extends ConsumerStatefulWidget {
  const CategoriesBottomSheetWidget({super.key, this.title});

  final String? title;

  @override
  ConsumerState<CategoriesBottomSheetWidget> createState() => _CategoriesBottomSheetWidgetState();
}

class _CategoriesBottomSheetWidgetState extends ConsumerState<CategoriesBottomSheetWidget> {
  final Logger log = Logger('CategoriesBottomSheetWidget');

  static final ScrollController _verticalController = ScrollController();

  final TextEditingController _searchController = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoryProvider);

    return AppBottomSheet(
      title: widget.title ?? "Categorie",
      initialSize: 0.5,
      minSize: 0.2,
      maxSize: 1.0,
      child: categoriesState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Errore: $e')),
        data: (categories) => Scrollbar(
          controller: _verticalController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _verticalController,
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: AppConstants.sizedBoxHeight),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomValidatedTextField(
                    controller: _searchController,
                    labelText: 'Cerca categoria',
                    prefixIcon: const Icon(Icons.search, size: 24),
                  ),
                ),

                const SizedBox(height: 8),
                ListView.builder(
                  controller: _verticalController,
                  shrinkWrap: true, // necessario senza Expanded
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return ListTile(
                      leading: const Icon(Icons.shopping_cart),
                      title: Text(category.name),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}