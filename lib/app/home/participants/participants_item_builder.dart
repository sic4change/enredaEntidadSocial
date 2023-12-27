import 'package:enreda_empresas/app/home/resources/left_empty_content.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:flutter/material.dart';

typedef ItemWidgetBuilder<T> = Widget Function(BuildContext context, T item);

class ParticipantsItemBuilder<T> extends StatelessWidget {
  const ParticipantsItemBuilder(
      {Key? key,
      required this.usersList,
      required this.itemBuilder,
      this.emptyTitle,
      this.emptyMessage,})
      : super(key: key);
  final List<UserEnreda> usersList;
  final ItemWidgetBuilder<UserEnreda> itemBuilder;
  final String? emptyTitle;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (usersList.isNotEmpty) {
      return _build(context, usersList);
    } else {
      return LeftEmptyContent(title: emptyTitle ?? '', message: emptyMessage ?? '');
    }
  }

  Widget _build(BuildContext context, List<UserEnreda> usersList) {

    final alignment = Responsive.isDesktop(context)? Alignment.topLeft: Alignment.topCenter;
    return Align(
      alignment: alignment,
      child: Wrap(
        children: usersList.map((c) => itemBuilder(context, c)).toList(),
        spacing: 15.0,
        runSpacing: 15.0,
      ),
    );
  }
}
