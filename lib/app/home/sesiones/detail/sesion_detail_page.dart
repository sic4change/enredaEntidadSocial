import 'package:enreda_empresas/app/home/sesiones/widgets/sesion_detail_content.dart';
import 'package:enreda_empresas/app/home/sesiones/widgets/sesion_list_tile.dart';
import 'package:enreda_empresas/app/models/sesion.dart';
import 'package:enreda_empresas/app/services/database.dart';
import 'package:enreda_empresas/app/utils/responsive.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Sesión detail page (Figma frame `1:94`).
///
/// Layout:
///   * Back button + "Sesiones" title.
///   * Collapsed [SesionListTile] so the user can verify which row they
///     tapped into.
///   * [SesionDetailContent] — the responsive two-card body (Título /
///     Desarrollo / Observaciones + Editar / Exportar CTAs on the left;
///     Participantes panel with 3-state attendance toggles on the right).
///     The same widget is reused inline beneath an expanded row.
///
/// Live data: subscribes to `Database.sesionStream(sesionId)` so external
/// edits (or the panel's own optimistic toggles) reflect immediately. The
/// initial Sesion is used until the stream emits.
class SesionDetailPage extends StatefulWidget {
  const SesionDetailPage({
    super.key,
    required this.initialSesion,
    required this.onClose,
    required this.onEdit,
    required this.onExport,
  });

  final Sesion initialSesion;
  final VoidCallback onClose;
  final ValueChanged<Sesion> onEdit;
  final ValueChanged<Sesion> onExport;

  @override
  State<SesionDetailPage> createState() => _SesionDetailPageState();
}

class _SesionDetailPageState extends State<SesionDetailPage> {
  late Stream<Sesion> _sesionStream;

  @override
  void initState() {
    super.initState();
    final database = Provider.of<Database>(context, listen: false);
    _sesionStream =
        database.sesionStream(widget.initialSesion.sesionId ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Sesion>(
      stream: _sesionStream,
      initialData: widget.initialSesion,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _ErrorView(
            message: snapshot.error.toString(),
            onClose: widget.onClose,
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final sesion = snapshot.data ?? widget.initialSesion;
        return _DetailBody(
          sesion: sesion,
          onClose: widget.onClose,
          onEdit: () => widget.onEdit(sesion),
          onExport: () => widget.onExport(sesion),
        );
      },
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.sesion,
    required this.onClose,
    required this.onEdit,
    required this.onExport,
  });

  final Sesion sesion;
  final VoidCallback onClose;
  final VoidCallback onEdit;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? Sizes.PADDING_16 : Sizes.PADDING_30,
        vertical: Sizes.PADDING_24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailHeader(onClose: onClose),
            const SizedBox(height: Sizes.PADDING_12),
            SesionListTile(sesion: sesion),
            const SizedBox(height: Sizes.PADDING_20),
            // SesionDetailContent renders without chrome (parent provides it).
            // This Container restores the shadowed card the body used to
            // carry inline — keeping the detail page visually intact while
            // the expanded-row case continues to use SesionListTile's outer
            // card as the unifying surface.
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(Sizes.RADIUS_16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary900.withOpacity(0.12),
                    blurRadius: Sizes.PADDING_20,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(Sizes.PADDING_12),
              clipBehavior: Clip.antiAlias,
              child: SesionDetailContent(
                sesion: sesion,
                onEdit: onEdit,
                onExport: onExport,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        TextButton.icon(
          onPressed: onClose,
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.primary900,
            size: Sizes.ICON_SIZE_20,
          ),
          label: Text(
            StringConst.SESIONES,
            style: textTheme.headlineSmall?.copyWith(
              color: AppColors.primary900,
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onClose});
  final String message;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Sizes.PADDING_30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.deleteRed,
              size: Sizes.ICON_SIZE_60,
            ),
            const SizedBox(height: Sizes.PADDING_16),
            Text(
              StringConst.SESION_DETAIL_NOT_FOUND,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.greyTxtAlt,
              ),
            ),
            const SizedBox(height: Sizes.PADDING_8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.greyTxtAlt,
              ),
            ),
            const SizedBox(height: Sizes.PADDING_20),
            TextButton(
              onPressed: onClose,
              child: const Text(StringConst.SESION_BUTTON_VOLVER),
            ),
          ],
        ),
      ),
    );
  }
}
