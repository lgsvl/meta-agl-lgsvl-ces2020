# Copyright (c) 2019 LG Electronics, Inc.

DEPENDS += "nodejs-native"
RDEPENDS_${PN} += "wam"

inherit aglwgt

S = "${WORKDIR}/git"

def get_nodejs_arch(d):
    target_arch = d.getVar('TRANSLATED_TARGET_ARCH', True)

    if target_arch == "x86-64":
        target_arch = "x64"
    elif target_arch == "aarch64":
        target_arch = "arm64"
    elif target_arch == "powerpc":
        target_arch = "ppc"
    elif target_arch == "powerpc64":
        target_arch = "ppc64"
    elif (target_arch == "i486" or target_arch == "i586" or target_arch == "i686"):
        target_arch = "ia32"

    return target_arch

NPM_BIN ?= "${STAGING_BINDIR_NATIVE}/npm"
NPM_CACHE_DIR ?= "${WORKDIR}/npm_cache"
NPM_REGISTRY ?= "http://registry.npmjs.org/"
NPM_ARCH = "${@get_nodejs_arch(d)}"
NPM_INSTALL_FLAGS ?= "--without-ssl --insecure --no-optional --verbose"

do_npm_install() {
    cd ${S}

    # remove old npm_modules folder
    rm -rf node_modules

    # configure cache to be in working directory
    ${NPM_BIN} set cache ${NPM_CACHE_DIR}

    # clear local cache prior to each compile
    ${NPM_BIN} cache clear --force

    ${NPM_BIN} --registry=${NPM_REGISTRY} --target_arch=${NPM_ARCH} ${NPM_INSTALL_FLAGS} install
}

addtask npm_install after do_configure before do_compile

