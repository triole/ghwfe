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
function ec() {
    printf '\e[1;34m%-12s\e[m %s\n' "${1}" "${2}"
}

function printerr() {
    echo "${1}"
    if [[ -z "${2}" ]]; then
        eval "${2}"
    fi
    exit 1
}

function install() {
    mkdir -p "${target_folder}"

    ec "Fetch from" "${url_prefix}/${url}"
    ec "Grep scheme" "${grep_scheme}"
    bin_url="$(
        curl -Ls "${url_prefix}/${url}" | grep -Po "${grep_scheme}"
    )"

    if [[ -z "${bin_url}" ]]; then
        echo "Unable to retrieve binary url. Fetch was empty."
        exit 1
    fi

    bin_url="$(
        echo ${url_prefix}/${bin_url} | sed "s,//,/,g" |
            sed "s,https:/,https://,g" |
            grep -Po "^https?://[a-zA-Z0-9_\-\=\./]+"
    )"

    last_url_part=$(echo "${bin_url}" | grep -Po "[^/]+$")
    tmpfil="/tmp/${last_url_part}"

    ec "Download" "${bin_url}"
    ec "To" "${tmpfil}"
    curl -sL ${bin_url} -o "${tmpfil}" ||
        printerr "Download failed"

    if [[ -z $(file ${tmpfil} | grep "executable") ]]; then
        ec "Extract to" "${target_folder}"
        tar xvf "${tmpfil}" -C "${target_folder}" ${strip_components} ||
            printerr "Extract failed" "file ${tmpfil}"
    else
        ec "Move bin to" "${target_folder}"
        mv -f "${tmpfil}" "${target_folder}"
    fi
}

install
