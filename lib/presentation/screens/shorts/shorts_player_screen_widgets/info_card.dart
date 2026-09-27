// ─── Kanal / Video Bilgi Kartı ──────────────────────────────────────────────
//
// Model-agnostik: hem ShortsPlayerScreen (ShortsModel) hem de tek üniversite
// oynatıcısı (VideoModel) tarafından, ilgili alanları düz parametre olarak
// geçirerek kullanılabilir — böylece iki ekran da BİREBİR aynı tasarımı
// paylaşır.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../utils/shorts_player_sizes.dart';

class ShortsPlayerInfoCard extends StatelessWidget {
  final ShortsPlayerSizes sizes;
  final String universityName;
  final String? logoUrl;
  final String description;
  final bool isFollowing;
  final VoidCallback onToggleFollow;
  final VoidCallback onWatchFull;

  const ShortsPlayerInfoCard({
    super.key,
    required this.sizes,
    required this.universityName,
    this.logoUrl,
    this.description = '',
    required this.isFollowing,
    required this.onToggleFollow,
    required this.onWatchFull,
  });

  @override
  Widget build(BuildContext context) {
    final hasLogo = logoUrl != null && logoUrl!.isNotEmpty;
    return Container(
      padding: EdgeInsets.all(sizes.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(sizes.cardBorderRadius),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: sizes.avatarSize,
                height: sizes.avatarSize,
                padding: EdgeInsets.all(sizes.avatarBorderWidth),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: ClipOval(
                  child: Container(
                    color: const Color(0xFF2A2A2A),
                    child: hasLogo
                        ? CachedNetworkImage(
                            imageUrl: logoUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (_, _, _) => const Icon(
                              Icons.school_rounded,
                              color: Colors.white54,
                            ),
                          )
                        : const Icon(Icons.school_rounded, color: Colors.white54),
                  ),
                ),
              ),
              SizedBox(width: sizes.cardPadding * 0.7),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            universityName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: sizes.channelNameFontSize,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.verified_rounded,
                          size: sizes.channelNameFontSize,
                          color: AppTheme.primaryColor,
                        ),
                      ],
                    ),
                    Text(
                      'Kampüs Kısa Videoları',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: sizes.channelSubFontSize,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: sizes.cardPadding * 0.5),
              GestureDetector(
                onTap: onToggleFollow,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(
                    horizontal: sizes.followBtnPaddingHorizontal,
                    vertical: sizes.followBtnPaddingVertical,
                  ),
                  decoration: BoxDecoration(
                    color: isFollowing
                        ? Colors.white.withValues(alpha: 0.1)
                        : AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(sizes.followBtnRadius),
                  ),
                  child: Text(
                    isFollowing ? 'Takip Ediliyor' : 'Takip Et',
                    style: TextStyle(
                      color: isFollowing ? AppTheme.primaryColor : Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: sizes.followBtnFontSize,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            SizedBox(height: sizes.sectionSpacing * 0.7),
            Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white70,
                fontSize: sizes.descriptionFontSize,
                height: sizes.descriptionLineHeight,
              ),
            ),
          ],
          SizedBox(height: sizes.sectionSpacing * 0.7),
          SizedBox(
            width: double.infinity,
            height: sizes.ctaHeight,
            child: ElevatedButton.icon(
              onPressed: onWatchFull,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(sizes.ctaRadius),
                ),
              ),
              icon: Icon(Icons.play_circle_fill_rounded, size: sizes.ctaIconSize),
              label: Text(
                'Videoyu Tam İzle',
                style: TextStyle(
                  fontSize: sizes.ctaFontSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
