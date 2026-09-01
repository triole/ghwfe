#!/bin/bash

dryrun="false"
sudo=""
for val in "$@"; do
  if [[ "${val}" =~ ^-+(s|sudo)$ ]]; then
    sudo="sudo "
  fi
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

target_folder="/usr"
[[ -n "${TARGET_FOLDER}" ]] && target_folder="${TARGET_FOLDER}"

tempfile="/tmp/golang.tar.gz"

export GOPATH="${HOME}/go"
export GOROOT="${target_folder}"

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
_rcmd ${sudo}tar -xf \"${tempfile}\" --directory \"${target_folder}\" --strip-components 1

_rcmd ls -la "${target_folder}"

which go || {
  echo "[error] go install failed"
  exit 1
}

_rcmd go version
