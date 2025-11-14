#!/bin/bash

target_folder="/usr/local"
[[ -n "${1}" ]] && target_folder="${1}"
[[ -n "${TARGET_FOLDER}" ]] && target_folder="${TARGET_FOLDER}"

tempfile="/tmp/golang.tar.gz"

debug="false"
for val in "$@"; do
  if [[ "${val}" =~ ^-+(d|debug)$ ]]; then
    debug="true"
  fi
done

rcmd() {
  echo "${1}"
  if [[ "${debug}" == "false" ]]; then
    eval "${1}"
  fi
}

get_latest_go_download_url() {
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
rcmd "tar -xf \"${tempfile}\" --directory \"${target_folder}\" --strip-components 1"

ls -la "${target_folder}"
rcmd "${target_folder}/bin/go version"
sleep 3
