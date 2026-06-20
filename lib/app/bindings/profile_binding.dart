import 'package:get/get.dart';
import '../../data/datasources/local/local_datasource.dart';
import '../../data/datasources/remote/supabase_datasource.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../data/repositories/profile_activity_repository.dart';
import '../../data/repositories/university_favorites_repository.dart';
import '../../presentation/controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
 @override
 void dependencies() {
   if (!Get.isRegistered<SupabaseDataSource>()) {
     Get.lazyPut(() => SupabaseDataSource(), fenix: true);
   }
   if (!Get.isRegistered<LocalDataSource>()) {
     Get.lazyPut(() => LocalDataSource(), fenix: true);
   }
   if (!Get.isRegistered<AuthRepository>()) {
     Get.lazyPut(
       () => AuthRepository(supabase: Get.find(), local: Get.find()),
       fenix: true,
     );
   }
   if (!Get.isRegistered<FavoritesRepository>()) {
     Get.lazyPut(
       () => FavoritesRepository(supabase: Get.find(), local: Get.find()),
       fenix: true,
     );
   }
   if (!Get.isRegistered<ProfileActivityRepository>()) {
     Get.lazyPut(
       () => ProfileActivityRepository(supabase: Get.find()),
       fenix: true,
     );
   }
   if (!Get.isRegistered<UniversityFavoritesRepository>()) {
     Get.lazyPut(
       () => UniversityFavoritesRepository(supabase: Get.find()),
       fenix: true,
     );
   }

   // Tag: route arguments'ta userId varsa o, yoksa mevcut kullanıcının ID'si.
   // Bu sayede FollowCountsWidget(userId: profile.id) her zaman doğru tag'i bulur.
   final args = Get.arguments as Map<String, dynamic>?;
   final targetUserId = args?['userId'] as String?;

   // Kendi profilimizse currentUser ID'sini tag olarak kullan
   final supabase = Get.find<SupabaseDataSource>();
   final currentUserId = supabase.currentUser?.id ?? 'anonymous';
   final tag = targetUserId ?? currentUserId;

   Get.put(
     ProfileController(
       authRepository: Get.find(),
       favoritesRepository: Get.find(),
       profileActivityRepository: Get.find(),
       universityFavoritesRepository: Get.find(),
     ),
     tag: tag,
   );
 }
}