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
implementation("com.digid:digid-sdk:3.0.0")
```

### 3. Permisos

**No hace falta declarar nada**: el SDK ya trae sus permisos y el manifest merger los fusiona en tu app.

> **No declares las features de cámara o GPS como `android:required="true"`.** El SDK las declara en `false` a propósito: si las marcas requeridas, Google Play deja de ofrecer **tu app** en cualquier equipo que no tenga ese hardware. La disponibilidad se comprueba en tiempo de ejecución.

Estos son los permisos que tu app termina declarando, y que debes reportar en el formulario de **Data Safety** de Play:

| Permiso | Origen | Para qué |
|---|---|---|
| `CAMERA` | SDK | Captura de documento y selfie |
| `INTERNET` | SDK | Comunicación con el servidor |
| `ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION` | SDK | Solo al firmar documentos con `required_gps`. Ningún otro flujo la pide |
| `ACCESS_NETWORK_STATE` | Motor de verificación | Detección de conectividad |
| `NFC` | Motor de verificación | Lectura de chip en pasaportes e identificaciones |
| `RECORD_AUDIO` | Motor de verificación | Grabación durante la prueba de vida |
| `POST_NOTIFICATIONS`, `VIBRATE`, `WAKE_LOCK` | Motor de verificación | Avisos y gestión de pantalla durante la verificación |

`POST_NOTIFICATIONS` requiere permiso en tiempo de ejecución desde Android 13.

### 4. Firma con ubicación (opcional)

Si alguno de tus documentos usa `required_gps`, el SDK pide la ubicación y la registra como constancia de la firma. No requiere configuración adicional: el permiso se solicita dentro del flujo, explicando para qué.

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
| 3.0.0   | 2026-08-11 | `isApproved` ahora exige que el servidor haya aprobado. Firma con ubicación (`required_gps`). El almacén de token deja de tumbar la app tras restaurar el teléfono. Un error del servidor al finalizar la firma ya no se reporta como éxito. **Cambios breaking** (ver migración). **Versión recomendada.** |
| 2.3.0   | 2026-08-03 | Zoom con pinch en la lectura del documento. La pantalla de T&C ahora la dicta el backend por cliente (sin cambios de integración). `address_data` agrega `municipio`, `colonia`, `numero_exterior`, `cruzamientos` y `parsing_confidence`. Corrige la orientación de la selfie del flujo de firma. |
| 2.2.0   | 2026-07-21 | `KycResult.sessionId` devuelve ahora el identificador que envía el integrador en `EXTRA_SESSION_ID` (antes devolvía siempre el interno). Nuevo error `DUPLICATE_SESSION_ID` cuando ese id ya se usó. |
| 2.1.0   | 2026-07-07 | Scores en Double (precisión), JSON con claves fijas (null explícito), `created_at`/`updated_at` en vez de `timestamp`, se quita `document.address`. |
| 2.0.1   | 2026-07-02 | Corrige un error de compilación de la 2.0.0.                                        |
| 2.0.0   | 2026-07-02 | Resultado KYC ampliado, descarga automática de imágenes y video, control de logs. **Cambios breaking** (ver migración). *No usar — reemplazada por 2.0.1.* |
| 1.3.0   | 2026-05-27 | Mejoras internas y de estabilidad                                                  |
| 1.2.0   | 2026-05-27 | Correcciones de errores silenciosos y mejoras de estabilidad                       |
| 1.1.0   | 2026-04-29 | Vista de Términos y Condiciones obligatoria (`DigidTermsConfig`)                    |
| 1.0.0   | 2026-04-25 | Release inicial                                                                    |

## Novedades de la 3.0.0

### Correcciones que cambian resultados

- **`isApproved` ya no puede dar un falso positivo.** Antes combinaba solo los tres sub-checks biométricos, así que un rechazo por rostro duplicado, dispositivo o IP en lista de bloqueo, o AML llegaba con los tres en `true` y la propiedad devolvía aprobado. Ahora exige además que el servidor haya dictado `Approved`.
- **Los puntajes del resultado parcial ya no se inventan.** Cuando el servidor no alcanza a entregar los datos completos, `faceMatchScore` y `livenessScore` llegan en `0.0` en vez de un `100.0` fabricado que se leía como biometría perfecta. Usa `ready` para saber si el resultado es completo.
- **Un fallo al finalizar la firma ya no se reporta como éxito.** Un error HTTP del servidor se entregaba como firma exitosa; ahora se propaga como error.

### Novedades

- **Firma con ubicación**: los documentos con `required_gps` ya se pueden firmar desde Android. El SDK pide el permiso en contexto, obtiene una lectura y corta antes de enviar si no la consigue, con opción de reintentar.
- **Motivos de rechazo con categoría**: `rejectionReasons` ahora dice qué parte falló, no solo el texto.
- **Estabilidad**: el almacén cifrado del token dejó de tumbar la app del integrador en bucle tras restaurar el teléfono o migrar de equipo. Y si el motor de verificación no devuelve el control al agotar los reintentos de una verificación rechazada, el SDK lo detecta consultando al servidor y entrega el resultado real.

### Migración desde 2.x

**`rejectionReasons` cambia de tipo.** Es el único cambio que rompe compilación:

```kotlin
// Antes — List<String>
result.rejectionReasons.forEach { motivo -> mostrar(motivo) }

// Ahora — List<KycRejectionReason>
result.rejectionReasons.forEach { motivo ->
    mostrar(motivo.message)      // texto legible, ya traducido por el servidor
    when (motivo.type) {         // "document", "face_match", "liveness"
        "liveness" -> repetirPruebaDeVida()
        else       -> repetirCapturaDeDocumento()
    }
}
```

En `toJson()` la clave `rejection_reasons` pasa de un arreglo de textos a uno de objetos `{type, message}`.

**Revisa tu uso de `isApproved`.** No cambia de firma, pero ahora devuelve `false` en casos donde antes devolvía `true`. Si tu backend registraba aprobaciones a partir de esa propiedad, es probable que tengas registros que el servidor sí rechazó.

**Peso de la app.** Esta versión actualiza el motor de verificación y el APK crece de forma notable (~25 MB adicionales medidos en una app de prueba en debug, sin minificar y con todas las ABI). Con R8 y App Bundle el impacto real es menor, pero conviene medirlo antes de publicar.

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
