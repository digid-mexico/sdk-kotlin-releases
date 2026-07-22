# DigidSDK — Android Releases

Repositorio público de distribución del **SDK de Digid para Android** (verificación KYC y firma digital de documentos).

Los clientes consumen el SDK desde el repositorio Maven alojado aquí; no necesitan clonar el código fuente ni configurar credenciales.

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
implementation("com.digid:digid-sdk:2.2.0")
```

### 3. Permisos en `AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-feature android:name="android.hardware.camera" android:required="true" />
```

## Inicialización

```kotlin
Digid.initialize(
    context = this,
    clientId = BuildConfig.DIGID_CLIENT_ID,
    token = BuildConfig.DIGID_TOKEN,
    environment = DigidEnvironment.SANDBOX   // .PRODUCTION en producción
)
```

Consulta el **Manual de Integración** para el detalle de los módulos KYC y de firma, el objeto `KycResult` y la personalización visual.

## Versiones disponibles

| Versión | Fecha      | Novedades                                                                          |
|---------|------------|------------------------------------------------------------------------------------|
| 2.2.0   | 2026-07-21 | `KycResult.sessionId` devuelve ahora el identificador que envía el integrador en `EXTRA_SESSION_ID` (antes devolvía siempre el interno). Nuevo error `DUPLICATE_SESSION_ID` cuando ese id ya se usó. **Versión recomendada.** |
| 2.1.0   | 2026-07-07 | Scores en Double (precisión), JSON con claves fijas (null explícito), `created_at`/`updated_at` en vez de `timestamp`, se quita `document.address`. |
| 2.0.1   | 2026-07-02 | Corrige un error de compilación de la 2.0.0.                                        |
| 2.0.0   | 2026-07-02 | Resultado KYC ampliado, descarga automática de imágenes y video, control de logs. **Cambios breaking** (ver migración). *No usar — reemplazada por 2.0.1.* |
| 1.3.0   | 2026-05-27 | Mejoras internas y de estabilidad                                                  |
| 1.2.0   | 2026-05-27 | Correcciones de errores silenciosos y mejoras de estabilidad                       |
| 1.1.0   | 2026-04-29 | Vista de Términos y Condiciones obligatoria (`DigidTermsConfig`)                    |
| 1.0.0   | 2026-04-25 | Release inicial                                                                    |

## Novedades de la 2.0.x

- **`KycResult` ampliado**: nuevos `status`, `ready`, `livenessMethod`, `ageEstimation`, `faceQuality`, `ipAnalysis` y `pdfUrl`.
- **`KycDocument` más completo**: `personalNumber`, `dateOfIssue`, `placeOfBirth`, `age`, domicilio estructurado (`addressData`) y campos OCR adicionales (`extraFieldsJson`).
- **Imágenes listas para usar**: el SDK descarga automáticamente frente, reverso, selfie y retrato, entregados como `Bitmap` (`frontImage`, `backImage`, `selfieImage`, `portraitImage`), además de sus URLs remotas.
- **Video de prueba de vida**: descargado a un archivo local listo para reproducir (`livenessVideoLocalPath`) y con la URL remota (`livenessVideoUrl`).
- **Control de logs**: `Digid.verboseLogging` y `Digid.engineLoggingEnabled` (ambos desactivados por defecto).

### Migración desde 1.x

- Se **elimina `KycResult.resources`** y los campos Base64 (`idFrontBase64`, `idBackBase64`, `selfieBase64`). Usa los `Bitmap` (`frontImage`, etc.) o las URLs.
- **`KycDocument`** cambió su lista de campos (nuevos parámetros y `addressData` / `extraFieldsJson`).
- El JSON de `toJson()` agrupa lo biométrico bajo `verification` (antes `kyc`) e incluye `images`, `ip_analysis`, `pdf_url` y `liveness_video`.

## Requisitos

- Android **minSdk 24** (Android 7.0+)
- **Kotlin 1.9+**
- **Java 17**
- **Android Gradle Plugin 8.0+**

## Soporte

Distribución confidencial para integradores autorizados de Digid.
