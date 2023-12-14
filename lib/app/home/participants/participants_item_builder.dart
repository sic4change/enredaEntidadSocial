import 'package:enreda_empresas/app/home/resources/empty_content.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:flutter/material.dart';

typedef ItemWidgetBuilder<T> = Widget Function(BuildContext context, T item);

class ParticipantsItemBuilder<T> extends StatelessWidget {
  const ParticipantsItemBuilder(
      {Key? key,
      required this.snapshot,
      required this.itemBuilder,
      this.emptyTitle,
      this.emptyMessage,
      this.fitSmallerLayout = false})
      : super(key: key);
  final AsyncSnapshot<List<T>> snapshot;
  final ItemWidgetBuilder<T> itemBuilder;
  final String? emptyTitle;
  final String? emptyMessage;
  final bool? fitSmallerLayout;

  @override
  Widget build(BuildContext context) {
    if (snapshot.hasData) {
      final List<T> items = snapshot.data!;
      if (items.isNotEmpty) {
        return _build(context, items);
      } else {
        return EmptyContent(
            title: emptyTitle ?? '', message: emptyMessage ?? '');
      }
    } else if (snapshot.hasError) {
      return const EmptyContent(
          title: 'Algo fue mal', message: 'No se pudo cargar los datos');
    }
    return const Center(child: CircularProgressIndicator());
  }

  Widget _build(BuildContext context, List<T> items) {

    final alignment = Responsive.isDesktop(context)? Alignment.topLeft: Alignment.topCenter;
    return Align(
      alignment: alignment,
      child: Wrap(
        children: items.map((c) => itemBuilder(context, c)).toList(),
        spacing: 15.0,
        runSpacing: 15.0,
      ),
    );
  }
}
