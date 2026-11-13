import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'report/image_encoder.dart';
import 'report/report_document.dart';

/// Registro de las tarjetas de la página de KPIs que se pueden capturar como
/// imagen para el informe descargable.
///
/// Cada tarjeta tiene una [GlobalKey] fija por título: además de localizarla
/// para la captura, conserva su estado (periodo, desagregación…) cuando la
/// tarjeta cambia de sitio en el árbol, p. ej. al pasar de los resultados de
/// búsqueda a la sección completa.
class KpiCaptureRegistry {
  final Map<String, GlobalKey> _keys = {};

  GlobalKey keyFor(String id) => _keys.putIfAbsent(id, GlobalKey.new);

  /// Captura la tarjeta [id] tal y como se ve ahora, o `null` si no está en
  /// pantalla (sección plegada o sin construir).
  Future<ReportImage?> capture(String id, {double pixelRatio = 2}) async {
    final renderObject = _keys[id]?.currentContext?.findRenderObject();
    if (renderObject is! RenderRepaintBoundary || !renderObject.hasSize) {
      return null;
    }
    try {
      final image = await renderObject.toImage(pixelRatio: pixelRatio);
      final bytes = await encodeReportImage(image);
      image.dispose();
      if (bytes == null) return null;
      return ReportImage(
        bytes,
        width: renderObject.size.width,
        height: renderObject.size.height,
      );
    } catch (e) {
      print('KPIs: no se pudo capturar la tarjeta "$id": $e');
      return null;
    }
  }

  /// Captura todas las tarjetas [ids] visibles. Entre una y otra deja pasar
  /// un frame para que la animación de carga no se congele, e informa del
  /// avance con [onProgress] (capturadas, total).
  Future<Map<String, ReportImage>> captureAll(
    List<String> ids, {
    void Function(int done, int total)? onProgress,
  }) async {
    final result = <String, ReportImage>{};
    for (int i = 0; i < ids.length; i++) {
      final image = await capture(ids[i]);
      if (image != null) result[ids[i]] = image;
      onProgress?.call(i + 1, ids.length);
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }
    return result;
  }
}

/// Pone el [KpiCaptureRegistry] a disposición de las tarjetas de la página.
class KpiCaptureScope extends InheritedWidget {
  final KpiCaptureRegistry registry;

  const KpiCaptureScope({
    Key? key,
    required this.registry,
    required Widget child,
  }) : super(key: key, child: child);

  static KpiCaptureRegistry? of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<KpiCaptureScope>()
      ?.registry;

  @override
  bool updateShouldNotify(KpiCaptureScope oldWidget) =>
      registry != oldWidget.registry;
}

/// Envuelve una tarjeta para poder capturarla con su título [id].
class KpiCapture extends StatelessWidget {
  final String id;
  final Widget child;

  const KpiCapture({Key? key, required this.id, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final registry = KpiCaptureScope.of(context);
    if (registry == null) return child;
    return RepaintBoundary(key: registry.keyFor(id), child: child);
  }
}
