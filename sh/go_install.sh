#!/bin/bash

target_folder="/usr/local"
[[ -n "${TARGET_FOLDER}" ]] && target_folder="${TARGET_FOLDER}"

tempfile="/tmp/golang.tar.gz"

export GOROOT="${target_folder}"

dryrun="false"
for val in "$@"; do
  if [[ "${val}" =~ ^-+(n|dryrun)$ ]]; then
    dryrun="true"
  fi
done

_rcmd() {
  cmd=${@}
  echo "${cmd}"
  if [[ "${dryrun}" == "false" ]]; then
    eval ${cmd}
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

_rcmd mkdir -p \"${target_folder}\"
_rcmd curl -sL \"$(get_latest_go_download_url)\" -o \"${tempfile}\"
_rcmd tar -xf \"${tempfile}\" --directory \"${target_folder}\" --strip-components 1

_rcmd ls -la "${target_folder}"
_rcmd ${target_folder}/bin/go version
sleep 3
