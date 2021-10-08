#!/bin/bash

tempdir="/tmp/assets"

base_dir="${1}"
if [[ -z "${base_dir}" ]]; then
    base_dir="${BASE_DIR}"
fi

if [[ "${base_dir:0:1}" != "/" ]]; then
    base_dir="$(pwd)/${base_dir}"
fi

if [[ "${base_dir: -1}" == "/" ]]; then
    base_dir="${base_dir:0:-1}"
fi

if [[ -z "${base_dir}" ]]; then
    echo -e "\nerror, please specify dir containing the builds\n"
    exit 1
fi

appname="$(echo ${base_dir} | grep -Po ".*(?=\/)" | grep -Po "[^/]+$")"
base_dir="$(realpath "${base_dir}")"

version_no=$(eval "${VERSION_COMMAND}")
if [[ -z "${version_no}" ]]; then
    bin=$(
        find "${base_dir}" -type f -executable |
            grep "linux_$(arch)"
    )
    version_no="$(
        ${bin} -V |
            grep -v "go version" | grep -Poi "version.*" | grep -Po "[^\s]+$"
    )"
fi

echo "Base dir: ${base_dir}"
echo "Version : ${version_no}"

function rcmd() {
    echo -e "\n\033[0;93m${1}\033[0m"
    eval ${1}
}

mkdir -p "${tempdir}"

for fol in $(find "${base_dir}" -maxdepth 1 -mindepth 1 -type d); do
    farch=$(echo "${fol}" | grep -Po "[^/]+$")
    tf="${appname}_v${version_no}_${farch}"
    cd "${fol}"
    pwd
    find "${fol}" -mindepth 1 -maxdepth 1 -type f -executable |
        head -n 1 |
        xargs -i md5sum {} |
        grep -Po "^[0-9a-f]+" \
            >"${tempdir}/${tf}.md5"
    rcmd "tar -zcvf ${tempdir}/${tf}.tar.gz *"
done
