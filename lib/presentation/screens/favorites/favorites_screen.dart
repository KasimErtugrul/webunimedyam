import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../../controllers/favorites_controller.dart';
import 'widgets/favorite_card_widget.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FavoritesController>();

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(title: const Text('Favorilerim')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        }

        if (controller.favoriteVideos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_outline_rounded,
                  color: AppTheme.textSec(context),
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'Henüz favori eklemediniz',
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Beğendiğiniz videoları favorilere ekleyin',
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.favoriteVideos.length,
          itemBuilder: (context, index) {
            return FavoriteCardWidget(video: controller.favoriteVideos[index]);
          },
        );
      }),
    );
  }
}

