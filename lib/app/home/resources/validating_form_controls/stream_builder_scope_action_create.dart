import 'package:enreda_empresas/app/models/scope_action.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:flutter/material.dart';
import '../../../sign_up/validating_form_controls/multi_select_button.dart';

Widget streamBuilderDropdownScopeActionCreate(BuildContext context, Set<ScopeAction> selectedScopeActions) {
  final scopeActionItems = LocationCache.instance.scopeActions
      .map((ScopeAction scopeAction) => MultiSelectDialogItem<ScopeAction>(scopeAction, scopeAction.name))
      .toList();

  return MultiSelectDialog<ScopeAction>(
    items: scopeActionItems,
    initialSelectedValues: selectedScopeActions,
  );
}
