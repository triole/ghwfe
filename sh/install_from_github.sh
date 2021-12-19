#!/bin/bash

# set and check args
url="${1}"
grep_scheme="${2}"
target_folder="${3}"
strip_components="${4}"

url_prefix="https://github.com"

if [[ -z "${url}" ]]; then
    url="${URL}"
fi
if [[ -z "${grep_scheme}" ]]; then
    grep_scheme="${GREP_SCHEME}"
fi
if [[ -z "${target_folder}" ]]; then
    target_folder="${TARGET_FOLDER}"
fi
if [[ -z "${strip_components}" ]]; then
    strip_components="${STRIP_COMPONENTS}"
fi
if [[ ${strip_components} =~ ^[0-9]+ ]]; then
    strip_components="--strip-components=${strip_components}"
else
    strip_components=""
fi

if [[ -z "${target_folder}" ]]; then
    echo -e "\nthree args required, provide url, grepscheme and target folder"
    echo -e "\ni.e. install_from_github.sh \\
        \"triole/lunr-indexer/releases/latest\" \\
        \"(?<=href\=\").*_linux_x86_64.tar.gz\" \\
        \"${HOME}/bin\""
    echo ""
    exit 1
fi

# functions and main
function install() {
    mkdir -p "${target_folder}"

    tmpfil="/tmp/tmp_install.tar.gz"
    echo "Fetch from    ${url_prefix}/${url}"
    echo "Grep scheme   ${grep_scheme}"
    bin_url="$(
        curl -Ls "${url_prefix}/${url}" | grep -Po "${grep_scheme}"
    )"

    if [[ -z "${bin_url}" ]]; then
        echo "Unable to retrieve binary url. Fetch was empty."
        exit 1
    fi

    bin_url="${url_prefix}/${bin_url}"
    echo "Download      ${bin_url}"
    curl -sL ${bin_url} -o "${tmpfil}" &&
        echo "Extract ${tmpfil}" &&
        tar xvf "${tmpfil}" -C "${target_folder}" ${strip_components} || (
        echo "Extract failed."
        file "${tmpfil}"
        exit 1
    )
}

install
