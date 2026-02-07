import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';

import '../../../../l10n/app_localizations.dart';

class SearchableDropdown extends StatefulWidget {
  final String? value;
  final String label;
  final List<String> items;
  final Function(String?) onChanged;

  const SearchableDropdown({
    Key? key,
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<SearchableDropdown> createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  final TextEditingController _searchController = TextEditingController();
  bool _isExpanded = false;
  List<String> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    setState(() {
      _filteredItems = widget.items
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
            height: 50.h,
            decoration: BoxDecoration(
              color: AppColors.textFieldColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.value ?? widget.label,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: widget.value == null ? Colors.grey : Colors.black,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          Container(
            margin: EdgeInsets.only(top: 4.h),
            padding: EdgeInsets.all(8.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.searchHint,
                    prefixIcon: const Icon(Icons.search),
                    contentPadding: EdgeInsets.symmetric(horizontal: 5.w),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onChanged: _filterItems,
                ),
                SizedBox(height: 8.h),
                Container(
                  constraints: BoxConstraints(maxHeight: 200.h),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        dense: true,
                        title: Text(
                          _filteredItems[index],
                          style: TextStyle(fontSize: 16.sp),
                        ),
                        onTap: () {
                          widget.onChanged(_filteredItems[index]);
                          setState(() {
                            _isExpanded = false;
                            _searchController.clear();
                            _filterItems('');
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
