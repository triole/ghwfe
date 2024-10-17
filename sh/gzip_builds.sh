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
version_command_args=("-V" "--version" "version")

printerr() {
  echo -e "$(date "+%Y-%m-%d %H:%M:%S") \033[0;31m[error]\033[0m ${1}"
}

find_binary() {
  bin="$(
    find "${source_folder}" -type f -executable |
      grep "linux_$(arch)" | sort | head -n 1
  )"
  if [[ -z "${bin}" ]]; then
    printerr "unable to detect binary"
    exit 1
  fi
  echo "${bin}"
}

for el in "${version_command_args[@]}"; do
  if [[ -z "${version_no}" ]]; then
    bin="$(find_binary)"
    version_no="$(
      eval ${bin} ${el} 2>/dev/null | grep -v "go version" |
        grep -Poi "version.*" | grep -Po "[0-9\.]+"
    )"
    if [[ -n "${version_no}" ]]; then
      break
    fi
  fi
done

if [[ -z "${version_no}" ]]; then
  echo "[error] can not get version number"
  exit 1
fi

echo "base dir: ${source_folder}"
echo "version : ${version_no}"

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
