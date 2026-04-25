# DigidSDK — Android Releases

Repositorio público de distribución del SDK de Digid para Android.

## Instalación

### 1. Añadir el repositorio Maven en `settings.gradle.kts`

```kotlin
dependencyResolutionManagement {
    repositories {
        google()
        mavenCentral()
        // DigidSDK
        maven { url = uri("https://raw.githubusercontent.com/digid-mexico/sdk-kotlin-releases/main/repository") }
    }
}
```

### 2. Agregar la dependencia en `build.gradle.kts` (módulo app)

```kotlin
implementation("com.digid:digid-sdk:1.0.0")
```

### 3. Permisos en `AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-feature android:name="android.hardware.camera" android:required="true" />
```

## Versiones disponibles

| Versión | Fecha      | Novedades                                   |
|---------|------------|---------------------------------------------|
| 1.0.0   | 2026-04-25 | Release inicial                             |

## Requisitos

- Android minSdk 24 (Android 7.0+)
- Kotlin 1.9+
- Java 17
