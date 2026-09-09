import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:enreda_empresas/app/home/participants/show_invitation_diaglog.dart';
import 'package:enreda_empresas/app/models/userEnreda.dart';
import 'package:enreda_empresas/app/services/location_cache.dart';
import 'package:enreda_empresas/app/values/strings.dart';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Compact participant card used by the Figma "Vista general" frames.
///
/// The card remains a single, reusable surface for both "Mis participantes"
/// and the entity-wide participant list. Its fixed rhythm makes all cards line
/// up even when names wrap to two lines.
class ParticipantsListTile extends StatelessWidget {
  const ParticipantsListTile({
    super.key,
    required this.user,
    required this.socialEntityUserId,
    this.onTap,
  });

  final UserEnreda user;
  final String socialEntityUserId;
  final VoidCallback? onTap;

  static const _cardRadius = 10.0;
  static const _footerHeight = 41.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Ver perfil de ${_fullName(user)}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(_cardRadius),
          hoverColor: AppColors.primary010,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: const Color(0xFFE5E5E5)),
              borderRadius: BorderRadius.circular(_cardRadius),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14054D5E),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(13, 7, 13, 7),
                    child: Column(
                      children: [
                        Text(
                          StringConst.GAMIFICATION,
                          style: const TextStyle(
                            color: AppColors.greyTxtAlt,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 3),
                        _GamificationProgress(
                          value: user.gamificationFlags.length,
                        ),
                        const SizedBox(height: 9),
                        _ParticipantAvatar(user: user),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 34,
                          child: Center(
                            child: Text(
                              _fullName(user),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.greyDark2,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                height: 1.12,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        _InviteButton(
                          onTap: () => showDialog(
                            context: context,
                            builder: (context) => ShowInvitationDialog(
                              user: user,
                              organizerId: socialEntityUserId,
                            ),
                          ),
                        ),
                        const SizedBox(height: 7),
                        _ContactRow(user: user),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: onTap,
                  child: Container(
                    height: _footerHeight,
                    width: double.infinity,
                    alignment: Alignment.center,
                    color: AppColors.turquoiseBlue,
                    child: Text(
                      StringConst.GO_PROFILE,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _fullName(UserEnreda user) =>
      '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();
}

class _GamificationProgress extends StatelessWidget {
  const _GamificationProgress({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    final maxFlags = math.max(1, LocationCache.instance.gamificationFlagsCount);
    final progress = (value / maxFlags).clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        height: 9,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 2,
              left: 0,
              right: 0,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.lightTurquoise,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            Positioned(
              top: 2,
              left: 0,
              width: constraints.maxWidth * progress,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.turquoise,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            Positioned(
              top: 1,
              left: (constraints.maxWidth * progress - 3.5)
                  .clamp(0.0, constraints.maxWidth - 7),
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.yellow,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParticipantAvatar extends StatelessWidget {
  const _ParticipantAvatar({required this.user});

  final UserEnreda user;

  @override
  Widget build(BuildContext context) {
    final photo = user.photo ?? '';
    final initials = _initials(user);
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white,
        border: Border.all(color: AppColors.primary020),
      ),
      padding: const EdgeInsets.all(2),
      child: ClipOval(
        child: ColoredBox(
          color: photo.isEmpty ? AppColors.pink600 : AppColors.white,
          child: photo.isEmpty
              ? Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : CachedNetworkImage(
                  imageUrl: photo,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: AppColors.turquoiseBlue,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  String _initials(UserEnreda user) {
    final firstName = user.firstName?.trim() ?? '';
    final lastName = user.lastName?.trim() ?? '';
    return '${firstName.isEmpty ? '' : firstName[0]}'
            '${lastName.isEmpty ? '' : lastName[0]}'
        .toUpperCase();
  }
}

class _InviteButton extends StatelessWidget {
  const _InviteButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: StringConst.INVITE_RESOURCE,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: SizedBox(
          height: 26,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.turquoiseButton2,
                  borderRadius: BorderRadius.circular(99),
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  StringConst.INVITE_RESOURCE,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.yellow,
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 17,
                    color: AppColors.turquoiseBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.user});

  final UserEnreda user;

  @override
  Widget build(BuildContext context) {
    final hasEmail = user.email.isNotEmpty;
    final hasPhone = user.phone?.isNotEmpty == true;
    return Row(
      children: [
        Expanded(
          child: _ContactAction(
            icon: Icons.mail_outline,
            label: StringConst.EMAIL,
            enabled: hasEmail,
            onTap: () => _sendEmail(user.email),
          ),
        ),
        Container(width: 1, height: 13, color: AppColors.grey100),
        Expanded(
          child: _ContactAction(
            icon: Icons.phone_outlined,
            label: StringConst.CALL,
            enabled: hasPhone,
            onTap: () => _call(user.phone!),
          ),
        ),
      ],
    );
  }

  Future<void> _sendEmail(String email) {
    final uri = Uri(scheme: 'mailto', path: email);
    return launchUrl(uri);
  }

  Future<void> _call(String phone) {
    final uri = Uri(scheme: 'tel', path: phone);
    return launchUrl(uri);
  }
}

class _ContactAction extends StatelessWidget {
  const _ContactAction({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? AppColors.greyTxtAlt : AppColors.greyBorder;
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
