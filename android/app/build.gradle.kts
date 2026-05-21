import java.util.Properties
import java.io.FileInputStream

// 1. Kotlin standartlarında properties yükleme yöntemi
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.developfly.unitv"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.developfly.unitv"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // build.gradle.kts içindeki ilgili bölümü bu şekilde güncelleyin:
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            // rootProject yerine project yazarak dosyanın app/ klasöründe olduğunu belirttik
            storeFile = keystoreProperties.getProperty("storeFile")?.let { project.file(it) }
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

    buildTypes {
        release {
            // 3. Oluşturduğumuz release imzasını buraya bağlıyoruz
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}