plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.dermatics.doctor_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" //flutter.ndkVersion

    compileOptions {
//        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.dermatics.doctor_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23 //flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = 7 //flutter.versionCode
        versionName = "1.0.6" //flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
//        release {
//            // TODO: Add your own signing config for the release build.
//            // Signing with the debug keys for now, so `flutter run --release` works.
//            signingConfig = signingConfigs.getByName("debug")
//        }
        getByName("release") {
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    //Add this to suppress lint warnings
    lint {
        disable.add("InvalidPackage")
        checkReleaseBuilds = false
        abortOnError = false
    }

    //Suppress Java compilation warnings
//    gradle.projectsEvaluated {
//        tasks.withType(JavaCompile) {
//            options.compilerArgs << "-Xlint:-options"
//            options.compilerArgs << "-Xlint:-deprecation"
//        }
//    }
}

/*java {
    toolchain {
        languageVersion.set(JavaLanguageVersion.of(11))
    }
}

tasks.withType<JavaCompile> {
    options.compilerArgs.add("-Xlint:-options")
}*/

// ✅ Suppress Java compilation warnings in Kotlin DSL
gradle.projectsEvaluated {
    tasks.withType<JavaCompile> {
        options.compilerArgs.addAll(listOf("-Xlint:-options", "-Xlint:-deprecation"))
    }
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")

    //Introduce Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:31.0.2"))

// Add dependencies for Firebase SDK for Google Analytics and FCM.
// When using BoM, do not specify the version in the Firebase dependency
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-messaging:23.2.1")
    implementation("im.zego:zpns-fcm:2.8.0")
//    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
