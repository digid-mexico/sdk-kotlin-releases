#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# mirror-didit.sh
#
# Espeja los artefactos Maven de Didit SDK en nuestro repositorio público.
# Esto permite que los clientes de DigidSDK configuren un único Maven URL
# y que Gradle resuelva todas las dependencias transitivas desde él,
# sin exponer que internamente usamos Didit.
#
# Uso:
#   cd sdk-android-releases
#   ./mirror-didit.sh           # espeja la versión definida en DIDIT_VERSION
#   ./mirror-didit.sh 3.5.0     # espeja una versión específica
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

DIDIT_VERSION="${1:-3.4.3}"
DIDIT_BASE="https://raw.githubusercontent.com/didit-protocol/sdk-android/main/repository"
DIDIT_GROUP_PATH="me/didit/didit-sdk"
LOCAL_PATH="repository/${DIDIT_GROUP_PATH}/${DIDIT_VERSION}"

echo "→ Espejando Didit SDK v${DIDIT_VERSION} en ${LOCAL_PATH}/"
mkdir -p "${LOCAL_PATH}"

# Artefactos a descargar
ARTIFACTS=(
    "didit-sdk-${DIDIT_VERSION}.aar"
    "didit-sdk-${DIDIT_VERSION}.pom"
    "didit-sdk-${DIDIT_VERSION}-sources.jar"
    "maven-metadata.xml"
)

for artifact in "${ARTIFACTS[@]}"; do
    src_url="${DIDIT_BASE}/${DIDIT_GROUP_PATH}/${DIDIT_VERSION}/${artifact}"

    # maven-metadata.xml vive en el directorio del grupo, no en la versión
    if [[ "${artifact}" == "maven-metadata.xml" ]]; then
        src_url="${DIDIT_BASE}/${DIDIT_GROUP_PATH}/maven-metadata.xml"
        dest="${LOCAL_PATH}/../maven-metadata.xml"
    else
        dest="${LOCAL_PATH}/${artifact}"
    fi

    echo "  ↓ ${artifact}"
    if curl -fsSL "${src_url}" -o "${dest}" 2>/dev/null; then
        echo "    ✓ OK"
    else
        echo "    ⚠ No encontrado (puede no existir): ${src_url}"
    fi
done

echo ""
echo "✓ Listo. Ahora commitea y sube:"
echo "  git add repository/${DIDIT_GROUP_PATH}/"
echo "  git commit -m \"mirror: didit-sdk v${DIDIT_VERSION}\""
echo "  git push origin main"
