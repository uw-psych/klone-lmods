#!/usr/bin/env bash
[[ "${XDEBUG:-}" =~ ^[1yYtT] ]] && set -x

set -o nounset -o errexit -o errtrace -o pipefail
shopt -s lastpipe

PROGNAME="${BASH_SOURCE[0]##*/}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

function _errexit() {
	local err=$?
	echo >&2 "Error: ${BASH_SOURCE[1]}: line ${BASH_LINENO[0]}: Command \"${BASH_COMMAND}\" failed with exit code ${err}"
	exit "${err}"
}

GROUP_NAME="${GROUP_NAME:-escience}"
MODULEFILES_DIR="${MODULEFILES_DIR:-/sw/contrib/modulefiles/${GROUP_NAME}}"
MODULES_DIR="${MODULES_DIR:-/sw/contrib/${GROUP_NAME}-src}"
APP_NAME="${APP_NAME:-restic}"
GH_REPO="restic/restic"

if [[ -z "${DLTMP:-}" ]]; then
	MADE_DLTMP="$(mktemp -d)"
	DLTMP="${MADE_DLTMP}"
fi
trap 'popd && [ -n "${MADE_DLTMP:-}" ] && rm -rf "${MADE_DLTMP}"' EXIT

curl -fL "https://api.github.com/repos/${GH_REPO}/releases/${GH_RELEASE_VERSION:-latest}" -o "${DLTMP}/release.json" || { echo >&2 "Failed to get latest version"; exit 1; }

pushd "${DLTMP}" >/dev/null
if [[ -z "${GH_RELEASE_VERSION:-}" ]]; then
	GH_RELEASE_VERSION="$(python3 -I -c 'import json; j=json.load(open("release.json","r")); print(j["tag_name"])' 2>/dev/null || { echo >&2 "Failed to get latest version"; exit 1; })"
fi

GH_ASSET="restic_${GH_RELEASE_VERSION#v}_linux_amd64.bz2"

GH_ASSET_URL="$(python3 -I -c 'import json; j=json.load(open("release.json","r")); print([a["browser_download_url"] for a in j["assets"] if a["name"] == "'"${GH_ASSET}"'"][0])' 2>/dev/null)" || { echo >&2 "Failed to get download URL"; exit 1; }

echo "Downloading ${GH_ASSET_URL}..."
curl -fL "${GH_ASSET_URL}" -o "${DLTMP}/${GH_ASSET}" || { echo >&2 "Failed to download ${GH_ASSET_URL}"; exit 1; }

echo "Extracting ${GH_ASSET}..."
bunzip2 "${DLTMP}/${GH_ASSET}" || { echo >&2 "Failed to extract ${GH_ASSET}"; exit 1; }
chmod +x "${DLTMP}/${GH_ASSET%.bz2}"
mv "${DLTMP}/${GH_ASSET%.bz2}" "${DLTMP}/${APP_NAME}"
mkdir -p "${DLTMP}/man"
"${DLTMP}/${APP_NAME}" generate --man "${DLTMP}/man"

APP_VERSION="${APP_VERSION:-${GH_RELEASE_VERSION#v}}"
APP_INSTALL_DIR="${APP_INSTALL_DIR:-${MODULES_DIR}/${APP_NAME}/${APP_VERSION}}"
APP_MODULE_DIR="${MODULEFILES_DIR}/${APP_NAME}"
echo "Installing ${APP_NAME} ${APP_VERSION} to ${APP_INSTALL_DIR}..."
umask 002 && mkdir -p "${APP_MODULE_DIR}" "${APP_INSTALL_DIR}/bin" "${APP_INSTALL_DIR}/share/man/man1" && rsync -lHP --chmod=a+rwX "${DLTMP}/${APP_NAME}" "${APP_INSTALL_DIR}/bin/" && rsync -lHP --chmod=a+rwX "${DLTMP}/man/"*.1 "${APP_INSTALL_DIR}/share/man/man1" && rsync -lHP --chmod=a+rwX "${SCRIPT_DIR}/modulefile.lua" "${APP_MODULE_DIR}/${APP_VERSION}.lua" && echo "Module ${GROUP_NAME}/${APP_NAME}/${APP_VERSION} installed."
