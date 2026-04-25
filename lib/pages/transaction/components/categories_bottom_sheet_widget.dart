import 'package:Billy/constants.dart';
import 'package:Billy/models/category_model.dart';
import 'package:Billy/models/create_category_response_model.dart';
import 'package:Billy/widgets/components/app_bottom_sheet.dart';
import 'package:Billy/providers/category_provider.dart';
import 'package:Billy/widgets/components/custom_button_widget.dart';
import 'package:Billy/widgets/components/custom_icon_widget.dart';
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

  final ScrollController _scrollListController = ScrollController();
  final ScrollController _scrollContentController = ScrollController();

  final TextEditingController _searchController = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollListController.dispose();
    _scrollContentController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String get _searchControllerText => _searchController.text;

  List<CategoryModel> _filterCategories(List<CategoryModel> categories, String query) {
    return categories.where((c) => c.name.toLowerCase().contains(query.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoryProvider);

    return AppBottomSheet(
      title: widget.title ?? "Categorie",
      initialSize: 0.9,
      minSize: 0.5,
      maxSize: 1.0,
      
      child: categoriesState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Errore: $e')),
        data: (categories) {
          final filteredCategories = _searchController.text.isEmpty
            ? categories
            : _filterCategories(categories, _searchController.text);

          return SingleChildScrollView(
            controller: _scrollContentController,
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: AppConstants.sizedBoxHeight),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomValidatedTextField(
                    controller: _searchController,
                    labelText: 'Cerca o digita per creare',
                    prefixIcon: const Icon(Icons.search, size: 24),
                    onChanged: (_) => setState(() {}), // forza rebuild per aggiornare il filtro
                  ),
                ),

                if (_searchControllerText.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.sizedBoxHeight / 2),
                  Text('${filteredCategories.length} categorie trovate'),
                
                  const SizedBox(height: 8),
                  CustomButtonWidget(
                    onPressed: () => Navigator.of(context).pop(CreateCategoryResponseModel(newName: _searchControllerText, isNew: true)),
                    text: 'Crea nuova categoria "$_searchControllerText"',
                    customIcon: CustomIconWidget(assetPath: 'assets/images/icons/add.PNG', size: 24, color: Theme.of(context).colorScheme.onSecondaryContainer),
                    isEnabled: true,
                  ),
                ],

                const SizedBox(height: 8),
                GridView.builder(
                  controller: _scrollListController,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    childAspectRatio: 1.5, // più largo che alto
                  ),
                  itemCount: filteredCategories.length,
                  itemBuilder: (context, index) {
                    final category = filteredCategories[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop(CreateCategoryResponseModel(category: category, isNew: false));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            category.icon,
                            const SizedBox(height: 4),
                            Text(
                              category.name,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

}