import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Fila de tarjetas de KPIs que comparten la misma altura (la de la más alta),
/// como en el diseño. Cada tarjeta ocupa un ancho fijo ([KpiCardRowItem.width])
/// o una parte proporcional del espacio restante ([KpiCardRowItem.flex]).
///
/// A diferencia de `IntrinsicHeight`, mide las tarjetas con un layout normal,
/// así que admite gráficas y `LayoutBuilder` dentro.
class KpiCardRow extends MultiChildRenderObjectWidget {
  final List<KpiCardRowItem> items;
  final double spacing;

  KpiCardRow({Key? key, required this.items, this.spacing = 20})
      : super(key: key, children: [for (final i in items) i.child]);

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderKpiCardRow(
        spacing: spacing,
        widths: [for (final i in items) i.width],
        flexes: [for (final i in items) i.flex],
      );

  @override
  void updateRenderObject(
      BuildContext context, _RenderKpiCardRow renderObject) {
    renderObject
      ..spacing = spacing
      ..widths = [for (final i in items) i.width]
      ..flexes = [for (final i in items) i.flex];
  }
}

/// Tarjeta de una [KpiCardRow]: con [width] fijo o con [flex].
class KpiCardRowItem {
  final Widget child;
  final double? width;
  final int flex;
  const KpiCardRowItem(this.child, {this.width, this.flex = 1});
}

class _KpiCardRowParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderKpiCardRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _KpiCardRowParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _KpiCardRowParentData> {
  _RenderKpiCardRow({
    required double spacing,
    required List<double?> widths,
    required List<int> flexes,
  })  : _spacing = spacing,
        _widths = widths,
        _flexes = flexes;

  double _spacing;
  set spacing(double v) {
    if (v == _spacing) return;
    _spacing = v;
    markNeedsLayout();
  }

  List<double?> _widths;
  set widths(List<double?> v) {
    if (listEquals(v, _widths)) return;
    _widths = v;
    markNeedsLayout();
  }

  List<int> _flexes;
  set flexes(List<int> v) {
    if (listEquals(v, _flexes)) return;
    _flexes = v;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _KpiCardRowParentData) {
      child.parentData = _KpiCardRowParentData();
    }
  }

  List<double> _childWidths(double maxWidth) {
    final n = childCount;
    final fixed = [
      for (int i = 0; i < n; i++) i < _widths.length ? _widths[i] : null
    ];
    final free = maxWidth -
        _spacing * (n - 1) -
        fixed.whereType<double>().fold<double>(0, (a, b) => a + b);
    int totalFlex = 0;
    for (int i = 0; i < n; i++) {
      if (fixed[i] == null) totalFlex += i < _flexes.length ? _flexes[i] : 1;
    }
    return [
      for (int i = 0; i < n; i++)
        fixed[i] ??
            (totalFlex == 0
                ? 0
                : (free * (i < _flexes.length ? _flexes[i] : 1) / totalFlex)
                    .clamp(0, double.infinity)),
    ];
  }

  @override
  void performLayout() {
    final maxWidth = constraints.maxWidth;
    final widths = _childWidths(maxWidth);

    // 1.ª pasada: altura natural de cada tarjeta
    double rowHeight = 0;
    var child = firstChild;
    var i = 0;
    while (child != null) {
      child.layout(BoxConstraints.tightFor(width: widths[i]),
          parentUsesSize: true);
      if (child.size.height > rowHeight) rowHeight = child.size.height;
      child = childAfter(child);
      i++;
    }

    // 2.ª pasada: todas al menos a la altura de la más alta. Se usa una altura
    // mínima (no fija) para que la tarjeta no se convierta en "relayout
    // boundary": si su contenido crece después (p. ej. al terminar de cargar
    // los datos), la fila se vuelve a calcular en lugar de desbordarse.
    double x = 0;
    child = firstChild;
    i = 0;
    while (child != null) {
      child.layout(
          BoxConstraints(
            minWidth: widths[i],
            maxWidth: widths[i],
            minHeight: rowHeight,
          ),
          parentUsesSize: true);
      if (child.size.height > rowHeight) rowHeight = child.size.height;
      (child.parentData! as _KpiCardRowParentData).offset = Offset(x, 0);
      x += widths[i] + _spacing;
      child = childAfter(child);
      i++;
    }

    size = constraints.constrain(Size(maxWidth, rowHeight));
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}

/// Dos columnas de tarjetas de KPIs con alturas independientes (las tarjetas
/// quedan intercaladas, como en el diseño) pero con la misma altura total: la
/// última tarjeta de la columna más corta se alarga hasta igualar la otra.
class KpiCardColumns extends MultiChildRenderObjectWidget {
  final List<Widget> left;
  final List<Widget> right;
  final double spacing;

  KpiCardColumns({
    Key? key,
    required this.left,
    required this.right,
    this.spacing = 20,
  }) : super(key: key, children: [...left, ...right]);

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderKpiCardColumns(leftCount: left.length, spacing: spacing);

  @override
  void updateRenderObject(
      BuildContext context, _RenderKpiCardColumns renderObject) {
    renderObject
      ..leftCount = left.length
      ..spacing = spacing;
  }
}

class _RenderKpiCardColumns extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _KpiCardRowParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _KpiCardRowParentData> {
  _RenderKpiCardColumns({required int leftCount, required double spacing})
      : _leftCount = leftCount,
        _spacing = spacing;

  int _leftCount;
  set leftCount(int v) {
    if (v == _leftCount) return;
    _leftCount = v;
    markNeedsLayout();
  }

  double _spacing;
  set spacing(double v) {
    if (v == _spacing) return;
    _spacing = v;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _KpiCardRowParentData) {
      child.parentData = _KpiCardRowParentData();
    }
  }

  @override
  void performLayout() {
    final maxWidth = constraints.maxWidth;
    final colWidth = ((maxWidth - _spacing) / 2).clamp(0.0, double.infinity);

    // Altura natural de cada tarjeta y de cada columna
    final columns = <List<RenderBox>>[[], []];
    var child = firstChild;
    var i = 0;
    while (child != null) {
      child.layout(BoxConstraints.tightFor(width: colWidth),
          parentUsesSize: true);
      columns[i < _leftCount ? 0 : 1].add(child);
      child = childAfter(child);
      i++;
    }
    double columnHeight(List<RenderBox> col) => col.isEmpty
        ? 0
        : col.fold<double>(0, (h, c) => h + c.size.height) +
            _spacing * (col.length - 1);
    final heights = [columnHeight(columns[0]), columnHeight(columns[1])];
    final total = heights[0] > heights[1] ? heights[0] : heights[1];

    // La última tarjeta de la columna más corta se alarga. Altura mínima (no
    // fija) para que, si su contenido crece luego, se recalcule todo.
    for (int c = 0; c < 2; c++) {
      final extra = total - heights[c];
      if (extra > 0.5 && columns[c].isNotEmpty) {
        final last = columns[c].last;
        last.layout(
          BoxConstraints(
            minWidth: colWidth,
            maxWidth: colWidth,
            minHeight: last.size.height + extra,
          ),
          parentUsesSize: true,
        );
      }
    }

    for (int c = 0; c < 2; c++) {
      double y = 0;
      for (final box in columns[c]) {
        (box.parentData! as _KpiCardRowParentData).offset =
            Offset(c == 0 ? 0 : colWidth + _spacing, y);
        y += box.size.height + _spacing;
      }
    }

    size = constraints.constrain(Size(maxWidth, total));
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
