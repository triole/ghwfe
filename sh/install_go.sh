#!/bin/bash

target_folder="${1}"
if [[ -z "${target_folder}" ]]; then
    target_folder="${TARGET_FOLDER}"
fi

tempfile="/tmp/golang.tar.gz"

debug="false"
for val in "$@"; do
    if [[ "${val}" =~ ^-+(d|debug)$ ]]; then
        debug="true"
    fi
done

function rcmd() {
    echo "${1}"
    if [[ "${debug}" == "false" ]]; then
        eval "${1}"
    fi
}

function get_latest_go_download_url() {
    url="https://golang.org/dl"
    r=$(
        curl -sL ${url} |
            grep -Po '(?<=href=").*linux-amd64.tar.gz(?=")' |
            head -n 1
    )
    echo "${url:0:-3}${r}"
}

rcmd "mkdir -p \"${target_folder}\""
rcmd "curl -sL \"$(get_latest_go_download_url)\" -o \"${tempfile}\""
rcmd "tar -xvf \"${tempfile}\" --directory \"${target_folder}\" --strip-components 1"
rcmd "ln -sf \"${target_folder}/bin/go\" \"${target_folder}/go\""

rcmd "${target_folder}/go version"
sleep 3
