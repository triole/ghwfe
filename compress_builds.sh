#!/bin/bash

tmpdir="/tmp/assets"

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

function getver() {
    fil=$(
        find "${base_dir}" -type f -executable |
            grep "linux_$(arch)" | head -n 1
    )
    eval "${fil}" -V | grep -Po "(?<=Version:\s).*"
}

function rcmd() {
    echo -e "\n\033[0;93m${1}\033[0m"
    eval ${1}
}

ver=$(getver)
echo $ver
if [[ -z "${ver}" ]]; then
    exit 1
fi
mkdir -p "${tmpdir}"

for fol in $(find "${base_dir}" -maxdepth 1 -mindepth 1 -type d); do
    farch=$(echo "${fol}" | grep -Po "[^/]+$")
    cd "${fol}"
    rcmd "tar -zcvf ${tmpdir}/${appname}_v${ver}_${farch}.tar.gz *"
done
