#!/bin/bash

architectures=(
    "linux_armv6l:GOOS=linux GOARCH=arm GOARM=6"
    "linux_armv7l:GOOS=linux GOARCH=arm GOARM=7"
    "linux_armv64:GOOS=linux GOARCH=arm64"
    "linux_i686:GOOS=linux GOARCH=386"
    "linux_x86_64:GOOS=linux GOARCH=amd64"
    "freebsd_arm64:GOOS=freebsd GOARCH=arm64"
    "freebsd_i686:GOOS=freebsd GOARCH=386"
    "freebsd_x86_64:GOOS=freebsd GOARCH=amd64"
    "darwin_arm64:GOOS=darwin GOARCH=arm64"
    "darwin_x86_64:GOOS=darwin GOARCH=amd64"
)

app_name=$(pwd | grep -Po "[^/]+$")

# ver=$(eval "${VERSION_COMMAND}")
# echo ${ver}
# if [[ -z "${ver}" ]]; then
#     echo "Software version required. Please specify \$VERSION_COMMAND"
#     exit 1
# fi

source_folder="${1}"
target_folder="${2}"
if [[ -z "${url}" ]]; then
    url="${URL}"
fi
if [[ -z "${source_folder}" ]]; then
    source_folder="${GITHUB_WORKSPACE}"
fi
if [[ -z "${target_folder}" ]]; then
    target_folder="${TARGET_FOLDER}"
fi

gobin="${GO_BIN_PATH}"

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

cd "${source_folder}"
rcmd "${gobin} mod init ${app_name}"
rcmd "${gobin} mod tidy"

for arch in "${architectures[@]}"; do
    arch_name="$(echo "${arch}" | grep -Po ".*(?=:)")"
    arch="$(echo "${arch}" | grep -Po "[^:]+$")"
    rcmd "${arch} CGO_ENABLED=0 ${gobin} build -a -o ${target_folder}/${arch_name}/${app_name} ."
done
