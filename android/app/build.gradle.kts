import java.util.Properties
import java.io.FileInputStream

// Keystore ayarlarını yükleme
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    // id("kotlin-android") // <-- Kaldırıldı: Built-in Kotlin yapısı için artık gerekli değil
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.developfly.unitv"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17

        // FIX: flutter_local_notifications v22+ bunu zorunlu kılıyor.
        // Eksikse build şu hatayla patlar:
        // "Dependency ':flutter_local_notifications' requires core library desugaring to be enabled"
        isCoreLibraryDesugaringEnabled = true
    }

    // kotlinOptions { ... } bloğu kaldırıldı

    defaultConfig {
        applicationId = "com.developfly.unitv"
        // FIX: flutter_local_notifications v22+, minSdk 24 (Android 7.0) zorunlu
        // kılıyor. flutter.minSdkVersion Flutter'ın kendi varsayılanına göre
        // (genelde 21) geldiği için, 24'ün altına düşerse maxOf ile üste çekiyoruz.
        minSdk = maxOf(flutter.minSdkVersion, 24)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storeFile = keystoreProperties.getProperty("storeFile")?.let { project.file(it) }
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

// Yeni Built-in Kotlin yapılandırması
kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

dependencies {
    // Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:34.14.0"))
    implementation("com.google.firebase:firebase-messaging")

    // FIX: flutter_local_notifications v22+ için zorunlu (isCoreLibraryDesugaringEnabled
    // ile birlikte çalışır — yukarısı derleyiciye, bu da runtime kütüphanesine karşılık gelir).
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

flutter {
    source = "../.."
}