#!/bin/bash

source_folder="${SOURCE_FOLDER}"
if [[ -z "${source_folder}" ]]; then
  source_folder="build"
fi
source_folder="$(realpath "${source_folder}")"

target_folder="${TARGET_FOLDER}"
if [[ -z "${target_folder}" ]]; then
  target_folder="/tmp/assets"
fi
target_folder="$(realpath "${target_folder}")"

appname="$(echo ${source_folder} | grep -Po ".*(?=\/)" | grep -Po "[^/]+$")"

version_no=$(eval "${VERSION_COMMAND}")
if [[ -z "${version_no}" ]]; then
  bin="$(find "${source_folder}" -type f -executable | grep "linux_$(arch)")"
  version_no="$(
    eval ${bin} -V | grep -v \"go version\" | grep -Poi \"version.*\" |
      grep -Po \"[^\s]+$\" || exit 1
  )"
fi
if [[ -z "${version_no}" ]]; then
  version_no="$(
    eval ${bin} version | grep -v \"go version\" | grep -Poi \"version.*\" |
      grep -Po \"[^\s]+$\" || exit 1
  )"
  version_no="$(eval "${cmd}" || exit 1)"
fi

echo "Base dir: ${source_folder}"
echo "Version : ${version_no}"

rcmd() {
  echo -e "\n\033[0;93m${1}\033[0m"
  eval ${1}
}

mkdir -p "${target_folder}"

for fol in $(find "${source_folder}" -maxdepth 1 -mindepth 1 -type d); do
  farch=$(echo "${fol}" | grep -Po "[^/]+$")
  tf="${appname}_v${version_no}_${farch}"
  cd "${fol}"
  find "${fol}" -mindepth 1 -maxdepth 1 -type f -executable |
    head -n 1 |
    xargs -i md5sum {} |
    grep -Po "^[0-9a-f]+" \
      >"${target_folder}/${tf}.md5"
  rcmd "tar -zcvf ${target_folder}/${tf}.tar.gz *"
done

echo -e "\n\033[0;93mResulting files\033[0m"
find "${target_folder}" -type f | sort
