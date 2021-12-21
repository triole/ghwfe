#!/bin/bash
IFS=$'\n'

source_folder="${SOURCE_FOLDER}"
if [[ -z "${source_folder}" ]]; then
    source_folder="${GITHUB_WORKSPACE}"
fi

go_root="${GOROOT}"
if [[ -z "${go_root}" ]]; then
    go_root="${GITHUB_WORKSPACE}"
fi

arr=($(find "$(realpath "${source_folder}")" -mindepth 1 -maxdepth 1 -type d))

for el in "${arr[@]}"; do
    src="${el}"
    pkg="$(echo "${el}" | grep -Po "^.*(?=/.*/)" | grep -Po "[^/]+$")"
    subpkg="$(echo "${el}" | grep -Po "[^/]+$")"
    trgfol="${go_root}/src/${pkg}"
    trg="${trgfol}/${subpkg}"

    mkdir -p "${trgfol}"
    echo -e "Try to make symlink\n\t${src} -> ${trg}"
    if [[ ! -f "${trg}" ]] && [[ ! -d "${trg}" ]] && [[ ! -L "${trg}" ]]; then
        cmd="ln -s \"${src}\" \"${trg}\""
        echo "${cmd}"
        eval "${cmd}"
    else
        echo "Target exists. Can not make symlink at ${trg}"
        exit 1
    fi
done
