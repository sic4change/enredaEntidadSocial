import 'package:enreda_empresas/app/common_widgets/search_rounded_container.dart';
import 'package:flutter/material.dart';

import '../../common_widgets/spaces.dart';
import '../../utils/responsive.dart';
import '../../values/values.dart';


class FilterTextFieldRow extends StatefulWidget {
  const FilterTextFieldRow(
      {Key? key,
        required this.searchTextController,
        required this.onFieldSubmitted,
        required this.onPressed,
        required this.clearFilter,
        required this.hintText,
      })
      : super(key: key);

  final TextEditingController searchTextController;
  final void Function(String) onFieldSubmitted;
  final void Function() onPressed;
  final void Function() clearFilter;
  final String hintText;

  @override
  State<FilterTextFieldRow> createState() => _FilterTextFieldRowState();
}

class _FilterTextFieldRowState extends State<FilterTextFieldRow> {
  bool _isClearTextVisible = false;

  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    widget.searchTextController.addListener(() {
      if (widget.searchTextController.text.isNotEmpty && !_isClearTextVisible) {
        setState(() {
          _isClearTextVisible = true;
        });
      } else if (widget.searchTextController.text.isEmpty &&
          _isClearTextVisible) {
        setState(() {
          _isClearTextVisible = false;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    double fontSize = Responsive.isMobile(context) ? 14 : 16;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: SearchRoundedContainer(
              height: Responsive.isMobile(context) ? 40 : 45,
              margin: EdgeInsets.only(left: 5, right: 5),
              child: Row(children: [
                SpaceW8(),
                Expanded(
                  child: TextFormField(
                    onFieldSubmitted: widget.onFieldSubmitted,
                    textInputAction: TextInputAction.done,
                    textAlignVertical: TextAlignVertical.center,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      border: InputBorder.none,
                    ),
                    controller: widget.searchTextController,
                    keyboardType: TextInputType.text,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.greyTxtAlt,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                      fontSize: fontSize,
                    ),
                  ),
                ),
                if (_isClearTextVisible)
                  IconButton(
                    padding: EdgeInsets.only(top: 8),
                    icon: Icon(Icons.clear, color: AppColors.greyDark),
                    onPressed: widget.clearFilter,
                  ),
                if (!_isClearTextVisible)
                  IconButton(
                    padding: EdgeInsets.only(top: 8),
                    icon: Icon(Icons.search, color: AppColors.greyDark),
                    onPressed: widget.onPressed,
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
