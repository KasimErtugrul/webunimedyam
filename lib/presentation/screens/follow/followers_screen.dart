// lib/presentation/screens/follow/followers_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/models/follow_model.dart';
import '../../../data/repositories/follow_repository.dart';
import '../../controllers/follow_controller.dart';

class FollowersScreen extends StatefulWidget {
  const FollowersScreen({super.key});

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen>
    with SingleTickerProviderStateMixin {
  late final FollowController _ctrl;
  late final TabController _tabController;
  late final String _userId;
  late final int _initialTab;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments as Map<String, dynamic>? ?? {};
    _userId = args['userId'] as String? ?? '';
    _initialTab = args['initialTab'] as int? ?? 0;

    // Önce profil ekranından tag'li controller'ı bulmayı dene.
    // Yoksa (örn. doğrudan açılırsa) kendi tag'iyle yeni bir tane oluştur.
    if (Get.isRegistered<FollowController>(tag: _userId)) {
      _ctrl = Get.find<FollowController>(tag: _userId);
    } else {
      _ctrl = Get.put(
        FollowController(followRepository: Get.find<FollowRepository>()),
        tag: _userId,
      );
    }

    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: _initialTab,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrl.loadFollowers(_userId);
      _ctrl.loadFollowing(_userId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Takip', style: TextStyle(fontSize: 20.sp)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Takipçiler'),
            Tab(text: 'Takip Edilenler'),
          ],
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSec(context),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _FollowList(
            listObs: _ctrl.followers,
            isLoadingObs: _ctrl.isFollowersLoading,
            emptyMessage: 'Henüz takipçi yok.',
            avatarKeyFn: (f) => f.followerAvatarUrl,
            nameFn: (f) => f.followerUsername ?? 'Kullanıcı',
            idFn: (f) => f.followerId,
          ),
          _FollowList(
            listObs: _ctrl.following,
            isLoadingObs: _ctrl.isFollowingLoading,
            emptyMessage: 'Henüz kimse takip edilmiyor.',
            avatarKeyFn: (f) => f.followingAvatarUrl,
            nameFn: (f) => f.followingUsername ?? 'Kullanıcı',
            idFn: (f) => f.followingId,
          ),
        ],
      ),
    );
  }
}

class _FollowList extends StatelessWidget {
  final RxList<FollowModel> listObs;
  final RxBool isLoadingObs;
  final String emptyMessage;
  final String? Function(FollowModel) avatarKeyFn;
  final String Function(FollowModel) nameFn;
  final String Function(FollowModel) idFn;

  const _FollowList({
    required this.listObs,
    required this.isLoadingObs,
    required this.emptyMessage,
    required this.avatarKeyFn,
    required this.nameFn,
    required this.idFn,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (isLoadingObs.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (listObs.isEmpty) {
        return Center(
          child: Text(
            emptyMessage,
            style: TextStyle(color: AppTheme.textSec(context), fontSize: 15.sp),
          ),
        );
      }
      return ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        itemCount: listObs.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: AppTheme.surface(context), indent: 72.w),
        itemBuilder: (context, i) {
          final item = listObs[i];
          final avatar = avatarKeyFn(item);
          final name = nameFn(item);
          final userId = idFn(item);

          return ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 4.h,
            ),
            leading: CircleAvatar(
              radius: 24.r,
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.15),
              backgroundImage: avatar != null ? NetworkImage(avatar) : null,
              child: avatar == null
                  ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : null,
            ),
            title: Text(
              name,
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: AppTheme.textSec(context),
              size: 20.sp,
            ),
            onTap: () =>
                Get.toNamed(AppRoutes.profile, arguments: {'userId': userId}),
          );
        },
      );
    });
  }
}
