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
implementation("com.digid:digid-sdk:3.4.1")
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
| 3.4.1   | 2026-11-20 | La selfie y la INE de la firma se suben nítidas y con su proporción: antes llegaban reducidas a 96 × 96 px y se veían pixeleadas en el documento firmado. Sin cambios de API ni de integración: basta con subir la versión del paquete. Sin cambios breaking. **Versión recomendada.** |
| 3.4.0   | 2026-09-24 | Un resultado con `ready = false` ya no es un veredicto: si el servidor no responde a tiempo llega como `"Pending"`. Nuevos `renapo`, `lista_nominal` y `code` en los motivos de rechazo. Sin cambios de permisos, dependencias ni funciones existentes. |
| 3.3.0   | 2026-09-18 | Contraste garantizado en los colores del tema: ningún `DigidTheme` puede dejar un elemento del SDK invisible por bajo contraste, se ajusta automáticamente. Sin cambios de API ni de integración. Sin cambios breaking. |
| 3.2.0   | 2026-09-04 | Motor de verificación interno actualizado. Sin cambios de API ni de integración: basta con subir la versión del paquete. Sin cambios breaking. |
| 3.1.0   | 2026-08-19 | `DigidTheme.accentColor` para teñir las ilustraciones (opt-in). La ubicación de la firma ya no falla en interiores. El botón inferior ya no queda bajo la navegación del sistema en Android 15 con `targetSdk 35`. Sin cambios breaking. |
| 3.0.0   | 2026-08-11 | `isApproved` ahora exige que el servidor haya aprobado. Firma con ubicación (`required_gps`). El almacén de token deja de tumbar la app tras restaurar el teléfono. Un error del servidor al finalizar la firma ya no se reporta como éxito. **Cambios breaking** (ver migración). |
| 2.3.0   | 2026-08-03 | Zoom con pinch en la lectura del documento. La pantalla de T&C ahora la dicta el backend por cliente (sin cambios de integración). `address_data` agrega `municipio`, `colonia`, `numero_exterior`, `cruzamientos` y `parsing_confidence`. Corrige la orientación de la selfie del flujo de firma. |
| 2.2.0   | 2026-07-21 | `KycResult.sessionId` devuelve ahora el identificador que envía el integrador en `EXTRA_SESSION_ID` (antes devolvía siempre el interno). Nuevo error `DUPLICATE_SESSION_ID` cuando ese id ya se usó. |
| 2.1.0   | 2026-07-07 | Scores en Double (precisión), JSON con claves fijas (null explícito), `created_at`/`updated_at` en vez de `timestamp`, se quita `document.address`. |
| 2.0.1   | 2026-07-02 | Corrige un error de compilación de la 2.0.0.                                        |
| 2.0.0   | 2026-07-02 | Resultado KYC ampliado, descarga automática de imágenes y video, control de logs. **Cambios breaking** (ver migración). *No usar — reemplazada por 2.0.1.* |
| 1.3.0   | 2026-05-27 | Mejoras internas y de estabilidad                                                  |
| 1.2.0   | 2026-05-27 | Correcciones de errores silenciosos y mejoras de estabilidad                       |
| 1.1.0   | 2026-04-29 | Vista de Términos y Condiciones obligatoria (`DigidTermsConfig`)                    |
| 1.0.0   | 2026-04-25 | Release inicial                                                                    |

## Novedades de la 3.4.1

### La selfie y la INE salen nítidas en el documento firmado

Las fotos que el SDK sube para la firma (la selfie de `SelfieCaptureActivity` y la selfie y la INE de `DigidSignatureService.uploadImages`) se reducían a un cuadrado de 96 × 96 px. En la hoja de evidencias del documento firmado se veían pixeleadas y la credencial aparecía deformada.

Ahora se suben en JPEG con su proporción original y hasta 1000 px por lado, suficiente para que se impriman nítidas. Una foto más chica se envía tal cual, sin agrandarla. La firma que recibe `DigidSignatureService.uploadImages` también conserva su proporción (sigue en PNG).

### Compatibilidad

No cambia ninguna API, permiso ni dependencia: basta con subir la versión del paquete. Cada foto pesa unos cientos de KB en lugar de unos pocos, así que la subida puede tardar un poco más en conexiones lentas. Los documentos firmados antes de actualizar no cambian.

## Novedades de la 3.4.0

### Un resultado con `ready = false` ya no es un veredicto

Si el servidor no entrega el veredicto dentro del tiempo de espera (~60 s), el `KycResult` llega con `ready = false`, `status = "Pending"` y `faceMatch`, `livenessCheck` y `documentValid` en `false`; `isApproved` devuelve `false`. Antes repetía el estado preliminar del análisis biométrico (por ejemplo `"Approved"` con `isApproved = true`), aunque el servidor todavía pudiera rechazar la verificación por las validaciones de RENAPO o de la lista nominal del INE.

**Qué hacer:** si `ready` es `false`, no registres la verificación como aprobada ni como rechazada: consulta el resultado definitivo desde tu backend con el `sessionId` (Manual de Integración, sección 4.5). Una verificación en revisión manual (`status = "In Review"`) también llega con `ready = false`. El `message` de estos resultados ahora dice "Resultado pendiente: consulta el veredicto definitivo en el servidor."

### RENAPO y lista nominal del INE en el resultado

Para los clientes con estas validaciones activas, `KycResult` agrega:

- `renapo`: `status`, `code`, `validations` (`curp`, `full_name`, `date_of_birth`, `gender`, `curp_status`) y `data` (registro de RENAPO).
- `lista_nominal`: `status` y `code`.
- En `rejectionReasons`, cada motivo trae además `code` (por ejemplo `RENAPO_BAJA`), `status` y `risk`.

Llevan los mismos nombres y valores que el JSON del servidor. `null` indica que no hay una consulta guardada para esa verificación.

```kotlin
val curpStatus = result.renapo?.validations?.curp_status   // "active", "cancelled", "not_available"
val credencial = result.lista_nominal?.status              // "vigente", "no_vigente", "no_encontrada"
result.rejectionReasons.forEach { Log.d("KYC", "${it.code}: ${it.message}") }
```

### Compatibilidad

No cambia ningún permiso, dependencia ni función existente: actualizar solo requiere subir la versión del paquete, y si no usas los campos nuevos tu integración sigue igual (salvo el caso de `ready = false` descrito arriba).

`toJson()` agrega las llaves `renapo` y `lista_nominal` (siempre presentes, `null` si no hubo consulta) y `status`/`code`/`risk` en cada motivo. Si tu backend deserializa ese JSON rechazando llaves desconocidas (por ejemplo `kotlinx.serialization` sin `ignoreUnknownKeys`, o Jackson con `FAIL_ON_UNKNOWN_PROPERTIES`), configúralo para ignorarlas.

## Novedades de la 3.3.0

### Contraste garantizado en los colores del tema

Ninguna combinación de colores que configures en `DigidTheme` puede dejar un elemento del SDK invisible. Antes, un `secondaryColor` demasiado parecido al fondo (por ejemplo, blanco sobre blanco) podía hacer que un botón perdiera su texto o su borde por completo. Ahora el SDK mide el contraste de cada color contra el fondo real sobre el que lo pinta y, si no alcanza el mínimo legible, lo ajusta automáticamente conservando el tono — sin que tengas que cambiar nada en tu integración.

Si tu tema ya tiene buen contraste, esta versión no cambia ni un pixel de tu app: es el requisito de idempotencia que valida la propia suite de tests del SDK.

Si no personalizaste `secondaryColor`, el valor por defecto cambia de `#2D8CF0` a `#0F71D8` (mismo tono, con mejor contraste) — es el único cambio visual de esta versión para quien use la configuración por defecto.

Si tu tema tiene una combinación de bajo contraste, además del ajuste automático verás un aviso en el log al inicializar el SDK, indicando qué colores conviene revisar.

Sin cambios de API ni de integración. Sin cambios breaking.

## Novedades de la 3.2.0

### Motor de verificación interno actualizado

Se actualiza el motor de verificación biométrica que usa el SDK. No cambia la API pública ni la integración: actualizar solo requiere subir la versión del paquete.

Además, el SDK ya no arrastra las dependencias de firma con monederos digitales, así que el repositorio JitPack deja de ser necesario. Si lo tienes declarado en tu `settings.gradle.kts` únicamente por el SDK de Digid, puedes quitarlo.

## Novedades de la 3.1.0

### Color de acento en las ilustraciones — opt-in

`DigidTheme` agrega `accentColor`, que tiñe los elementos decorativos verde azulado de las ilustraciones del SDK (hoy, la pantalla de Términos y Condiciones):

```kotlin
DigidTheme(
    primaryColor = "#1A3C6E",
    secondaryColor = "#2D8CF0",
    backgroundColor = "#FFFFFF",
    accentColor = "#1A3C6E"   // opcional
)
```

> **Es opt-in a propósito**: si no lo configuras, las ilustraciones conservan su color original (`#6AC1B4`) — actualizar el SDK no cambia nada visualmente. Los botones y cabeceras siguen usando `primaryColor`; si quieres que la ilustración acompañe a tu tema, pasa `accentColor` explícitamente.

### Correcciones

- **La ubicación de la firma ya no falla en interiores.** Con el permiso concedido y el GPS activo, obtener la coordenada podía fallar 2 o más veces antes de funcionar: solo se consultaba el proveedor GPS, cuyo fix en interiores tarda más que el plazo. Ahora se consultan todos los proveedores en paralelo (el de red responde en segundos), hay respaldo de lectura previa, y al finalizar se espera la petición en vuelo con progreso en vez de mostrar un error inmediato.
- **El botón inferior ya no queda bajo la navegación del sistema.** En Android 15 con `targetSdk 35` (obligatorio en Play desde agosto 2026), la primera entrada al flujo podía dejar el botón Continuar debajo de la barra de navegación, intapeable con 3 botones. Afectaba las cinco vistas del SDK de forma intermitente.

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
