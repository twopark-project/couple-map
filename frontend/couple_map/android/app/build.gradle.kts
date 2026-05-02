plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

import java.util.Properties
import java.io.FileInputStream

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { localProperties.load(it) }
}

fun readKey(name: String): String =
    System.getenv(name) ?: localProperties.getProperty(name) ?: ""

fun requireKey(name: String): String {
    val value = readKey(name)
    if (value.isEmpty()) {
        throw GradleException("Required key '$name' is missing. Set it in local.properties or environment.")
    }
    return value
}

android {
    namespace = "com.twoPark.couple_map"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.twoPark.couple_map"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        manifestPlaceholders["KAKAO_NATIVE_APP_KEY"] = requireKey("KAKAO_NATIVE_APP_KEY")
        manifestPlaceholders["NAVER_CLIENT_ID"] = readKey("NAVER_CLIENT_ID")
        manifestPlaceholders["NAVER_CLIENT_SECRET"] = readKey("NAVER_CLIENT_SECRET")
        manifestPlaceholders["NAVER_CLIENT_NAME"] = readKey("NAVER_CLIENT_NAME")
    }

    signingConfigs {
        create("release") {
            val storeFilePath = readKey("RELEASE_STORE_FILE")
            val storePass = readKey("RELEASE_STORE_PASSWORD")
            val alias = readKey("RELEASE_KEY_ALIAS")
            val keyPass = readKey("RELEASE_KEY_PASSWORD")

            if (storeFilePath.isNotEmpty()) {
                storeFile = file(storeFilePath)
                storePassword = storePass
                keyAlias = alias
                keyPassword = keyPass
            }
        }
    }

    buildTypes {
        debug {
            manifestPlaceholders["networkSecurityConfig"] = "network_security_config_dev"
        }
        release {
            signingConfig = signingConfigs.getByName("release")

            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )

            manifestPlaceholders["networkSecurityConfig"] = "network_security_config"
        }
    }
}

val validateReleaseSecrets by tasks.registering {
    doLast {
        val storeFilePath = requireKey("RELEASE_STORE_FILE")
        requireKey("RELEASE_STORE_PASSWORD")
        requireKey("RELEASE_KEY_ALIAS")
        requireKey("RELEASE_KEY_PASSWORD")
        requireKey("NAVER_CLIENT_ID")
        requireKey("NAVER_CLIENT_SECRET")
        requireKey("NAVER_CLIENT_NAME")

        if (!file(storeFilePath).exists()) {
            throw GradleException("Keystore file not found: $storeFilePath")
        }
    }
}

tasks.matching {
    (it.name.startsWith("assemble") || it.name.startsWith("bundle")) &&
        it.name.endsWith("Release")
}.configureEach {
    dependsOn(validateReleaseSecrets)
}

flutter {
    source = "../.."
}
