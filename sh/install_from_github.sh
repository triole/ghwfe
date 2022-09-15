#!/bin/bash

# set and check args
url="${1}"
grep_scheme="${2}"
target_folder="${3}"
strip_components="${4}"
# https://api.github.com/repos/triole/lunr-indexer/releases
url_prefix="https://api.github.com/repos"
curl_cmd="curl -Ls"

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

function is_exec() {
    if [[ -n "$(od -N4 -c "${1}" | tr -d ' ' | grep -E "ELF$")" ]]; then
        echo "true"
    else
        echo "false"
    fi
}

function printerr() {
    echo -e "\033[0;91m${1}\033[0m"
    if [[ -z "${2}" ]]; then
        eval "${2}"
    fi
    exit 1
}

function install() {
    mkdir -p "${target_folder}"
    fetch_url="${url_prefix}/${url}/releases/latest"
    ec "Fetch from" "${fetch_url}"
    ec "Grep scheme" "${grep_scheme}"

    response="$(${curl_cmd} "${fetch_url}")"

    hrefs=($(
        echo "${response}" |
            grep -Po '(?<="browser_download_url":).*' | tr -d '"'
    ))

    if [[ "${#hrefs[@]}" == "0" ]]; then
        echo "${response}"
        printerr "No urls found. Check response above."
    fi

    for el in "${hrefs[@]}"; do
        bin_url="$(echo "${el}" | grep "${grep_scheme}")"
        if [[ -n "${bin_url}" ]]; then
            break
        fi
    done

    if [[ -z "${bin_url}" ]]; then
        for el in "${hrefs[@]}"; do
            echo "${el}"
        done
        echo -e "\n\033[0;91mNone of the urls above did match. Check grep scheme.\033[0m"
        exit 1
    fi

    last_url_part=$(echo "${bin_url}" | grep -Po "[^/]+$")
    tmpfil="/tmp/${last_url_part}"

    ec "Download" "${bin_url}"
    ec "To" "${tmpfil}"
    ${curl_cmd} ${bin_url} -o "${tmpfil}" || printerr "Download failed"

    if [[ "$(is_exec "${tmpfil}")" == "false" ]]; then
        ec "Extract to" "${target_folder}"
        tar xvf "${tmpfil}" -C "${target_folder}" ${strip_components} ||
            printerr "Extract failed" "file ${tmpfil}"
    else
        ec "Move bin to" "${target_folder}"
        mv -f "${tmpfil}" "${target_folder}"
    fi
}

install
