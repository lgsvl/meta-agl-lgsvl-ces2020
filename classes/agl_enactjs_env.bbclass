# Copyright (c) 2017-2019 LG Electronics, Inc.
#
# agl_enactjs_env
#
# Base-level bbclass to setup the development environment for Enact code.
# Provides access to enact-dev, Node, and NPM.
#

# Dependencies:
#   - enact-dev-native to get enact-dev and npm
DEPENDS_append = " enact-dev-native"

# Allow overriding the path to the enact-dev tools, in case an app needs
# to pull in a different version
AGL_ENACTJS_TOOL_PATH ??= "${STAGING_DIR_NATIVE}/opt/enact-dev"

ENACT_NODE ??= "${AGL_ENACTJS_TOOL_PATH}/node_binaries/${BUILD_ARCH}/node"
ENACT_DEV ??= "${ENACT_NODE} ${AGL_ENACTJS_TOOL_PATH}/bin/enact.js"
ENACT_NPM ??= "${AGL_ENACTJS_TOOL_PATH}/node_binaries/${BUILD_ARCH}/npm"

do_compile_prepend() {
    # changing the home directory to the working directory, the .npmrc will be created in this directory
    export HOME=${WORKDIR}

    # configure cache to be in the cache directory
    bbnote "BUILD_ARCH = ${BUILD_ARCH}"
    bbnote "ENACT_NPM = ${ENACT_NPM}"
    bbnote "Enact do_compile_prepend set npm cache"
    ${ENACT_NPM} set cache ${TMPDIR}/npm_cache

    # Prefer using offline cached packages
    bbnote "Enact do_compile_prepend config npm offline"
    ${ENACT_NPM} config set prefer-offline true

    # Fix to prevent NPM from not honoring shrinkwrap; see https://github.com/npm/npm/issues/17960
    bbnote "Enact do_compile_prepend config npm package-lock"
    ${ENACT_NPM} config set package-lock true

    # Tell NPM to run packages using the Node binary that started it
    bbnote "Enact do_compile_prepend config npm node-path"
    ${ENACT_NPM} config set scripts-prepend-node-path true

    # explicity set NPM registry URI
    bbnote "Enact do_compile_prepend set npm registry"
    ${ENACT_NPM} set registry https://registry.npmjs.org/
}
