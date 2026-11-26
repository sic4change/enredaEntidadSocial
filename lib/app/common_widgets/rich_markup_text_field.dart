import 'package:enreda_empresas/app/common_widgets/markup_text_editing_controller.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Multi-line text field that lets the user apply **bold** / *italic* to parts
/// of the text through a small toolbar that floats over the focused field
/// (also Ctrl/Cmd + B and Ctrl/Cmd + I).
///
/// The value is stored as a plain string with inline markup (see
/// `markup_text.dart`). If an external [controller] is given it is kept in
/// sync, so existing forms keep reading/writing `controller.text` as before.
class RichMarkupTextField extends StatefulWidget {
  const RichMarkupTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.decoration,
    this.style,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.keyboardType,
    this.enabled = true,
    this.onTap,
    this.readOnly = false,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final InputDecoration? decoration;
  final TextStyle? style;
  final String? Function(String?)? validator;
  final Function(String?)? onSaved;
  final Function(String)? onChanged;
  final TextInputType? keyboardType;
  final bool enabled;
  final VoidCallback? onTap;
  final bool readOnly;

  @override
  State<RichMarkupTextField> createState() => _RichMarkupTextFieldState();
}

class _RichMarkupTextFieldState extends State<RichMarkupTextField> {
  late final MarkupTextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  final OverlayPortalController _toolbar = OverlayPortalController();

  bool get _canFormat => widget.enabled && !widget.readOnly;

  @override
  void initState() {
    super.initState();
    _controller = MarkupTextEditingController(
      text: widget.controller?.text ?? widget.initialValue ?? '',
    );
    _controller.addListener(_pushToExternal);
    widget.controller?.addListener(_pullFromExternal);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant RichMarkupTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_pullFromExternal);
      widget.controller?.addListener(_pullFromExternal);
      _pullFromExternal();
    }
    if (!_canFormat && _toolbar.isShowing) _toolbar.hide();
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_pullFromExternal);
    _controller.removeListener(_pushToExternal);
    _focusNode.removeListener(_onFocusChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _pushToExternal() {
    final external = widget.controller;
    if (external != null && external.text != _controller.text) {
      external.text = _controller.text;
    }
  }

  void _pullFromExternal() {
    final external = widget.controller;
    if (external != null && external.text != _controller.text) {
      _controller.text = external.text;
    }
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus && _canFormat) {
      _toolbar.show();
    } else {
      _toolbar.hide();
    }
  }

  void _bold() {
    if (_canFormat) _controller.toggleBold();
  }

  void _italic() {
    if (_canFormat) _controller.toggleItalic();
  }

  @override
  Widget build(BuildContext context) {
    final field = TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: widget.decoration,
      maxLines: null,
      validator: widget.validator,
      onSaved: widget.onSaved,
      keyboardType: widget.keyboardType,
      onChanged: widget.onChanged,
      enabled: widget.enabled,
      onTap: widget.onTap,
      readOnly: widget.readOnly,
      style: widget.style,
    );

    // Positioned with overlayChildLayoutBuilder (not CompositedTransform*):
    // the Tooltips inside the toolbar need a reliable paint transform.
    return OverlayPortal.overlayChildLayoutBuilder(
      controller: _toolbar,
      overlayChildBuilder: (context, info) {
        final fieldRect = MatrixUtils.transformRect(
          info.childPaintTransform,
          Offset.zero & info.childSize,
        );
        return Stack(
          children: [
            Positioned(
              right: info.overlaySize.width - fieldRect.right,
              bottom: info.overlaySize.height - fieldRect.top + 2,
              child: TextFieldTapRegion(
                child: ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) => _FormatToolbar(
                    boldActive: _controller.isBoldActive(),
                    italicActive: _controller.isItalicActive(),
                    onBold: _bold,
                    onItalic: _italic,
                  ),
                ),
              ),
            ),
          ],
        );
      },
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyB, control: true): _bold,
          const SingleActivator(LogicalKeyboardKey.keyB, meta: true): _bold,
          const SingleActivator(LogicalKeyboardKey.keyI, control: true): _italic,
          const SingleActivator(LogicalKeyboardKey.keyI, meta: true): _italic,
        },
        child: field,
      ),
    );
  }
}

class _FormatToolbar extends StatelessWidget {
  const _FormatToolbar({
    required this.boldActive,
    required this.italicActive,
    required this.onBold,
    required this.onItalic,
  });

  final bool boldActive;
  final bool italicActive;
  final VoidCallback onBold;
  final VoidCallback onItalic;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      color: Colors.white,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _FormatButton(
              icon: Icons.format_bold,
              tooltip: 'Negrita (Ctrl/⌘+B)',
              active: boldActive,
              onPressed: onBold,
            ),
            _FormatButton(
              icon: Icons.format_italic,
              tooltip: 'Cursiva (Ctrl/⌘+I)',
              active: italicActive,
              onPressed: onItalic,
            ),
          ],
        ),
      ),
    );
  }
}

class _FormatButton extends StatelessWidget {
  const _FormatButton({
    required this.icon,
    required this.tooltip,
    required this.active,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        canRequestFocus: false,
        borderRadius: BorderRadius.circular(4),
        onTap: onPressed,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: active ? AppColors.greyUltraLight : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, size: 18, color: AppColors.greyDark),
        ),
      ),
    );
  }
}
