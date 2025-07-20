import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keyStoreProperties = Properties()
val keyStoreFile = rootProject.file("key.properties")
if (keyStoreFile.exists()) {
    keyStoreFile.inputStream().use { keyStoreProperties.load(it) }
}

android {
    namespace = "com.tium.tium"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.tium.tium"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            storeFile = file(keyStoreProperties["storeFile"] as String)
            storePassword = keyStoreProperties["storePassword"] as String
            keyAlias = keyStoreProperties["keyAlias"] as String
            keyPassword = keyStoreProperties["keyPassword"] as String
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }


    compileOptions {
        // ✅ Java 11 호환
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11

        // ✅ desugaring 활성화
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
