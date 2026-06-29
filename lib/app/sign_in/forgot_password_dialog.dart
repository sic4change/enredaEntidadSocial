import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../values/values.dart';

const _waveLineSvg = '''
<svg width="979" height="487" viewBox="0 0 979 487" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M975.877 73.1619C939.868 79.4243 858.674 88.1916 821.967 73.1619C776.083 54.3748 777.89 21.1361 706.354 21.1361C640.897 21.1361 609.528 80.7491 570.87 91.9491C532.212 103.149 510.534 86.891 515.954 38.8393C521.373 -9.21239 562.56 -9.93498 551.36 38.8393C540.16 87.6136 478.668 268.259 320.857 268.259C269.554 268.259 216.805 232.852 216.805 165.291C216.805 97.7297 264.496 60.1555 320.857 60.1555C377.218 60.1555 427.076 99.1749 427.076 165.291C427.076 268.259 212.439 483.529 2.52881 483.529" stroke="#FFCB77" stroke-width="5.05807" stroke-linecap="round"/>
</svg>
''';

/// Brand-styled confirmation dialog for the "olvidé contraseña" flow.
/// Returns `true` if the user confirms.
Future<bool?> showForgotPasswordDialog(
  BuildContext context, {
  required String title,
  required String content,
  required String confirmLabel,
  required String cancelLabel,
}) {
  final textTheme = Theme.of(context).textTheme;

  return showDialog<bool>(
    context: context,
    barrierColor: Colors.black54,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 575),
        child: AspectRatio(
          aspectRatio: 1000 / 575,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.primary900,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 10,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(Sizes.PADDING_20),
                      child: SvgPicture.string(
                        _waveLineSvg,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(Sizes.PADDING_40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: textTheme.titleLarge?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: Sizes.PADDING_20),
                        Text(
                          content,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.white,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: Sizes.PADDING_32),
                        Wrap(
                          spacing: Sizes.PADDING_16,
                          runSpacing: Sizes.PADDING_12,
                          alignment: WrapAlignment.center,
                          children: [
                            OutlinedButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.white,
                                side: const BorderSide(
                                  color: AppColors.white,
                                  width: 1.5,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Sizes.PADDING_32,
                                  vertical: Sizes.PADDING_14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(Sizes.RADIUS_25),
                                ),
                              ),
                              child: Text(
                                cancelLabel,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.yellow,
                                foregroundColor: AppColors.primary900,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Sizes.PADDING_32,
                                  vertical: Sizes.PADDING_14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(Sizes.RADIUS_25),
                                ),
                              ),
                              child: Text(
                                confirmLabel,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.primary900,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
