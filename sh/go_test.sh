#!/bin/bash

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

go_root="/usr/local"
[[ -n "${GOROOT}" ]] && go_root="${goroot}"

export GOROOT="${go_root}"

source_folder="${SOURCE_FOLDER}"
[[ -z "${source_folder}" ]] && source_folder="${GITHUB_WORKSPACE}"

source_folder="$(realpath "${source_folder}")"

target_folder="${TARGET_FOLDER}"
[[ -z "${target_folder}" ]] && target_folder="/tmp/assets"

target_folder="$(realpath "${target_folder}")"

mkdir -p "${target_folder}"

_rcmd go test -v -race -cover -bench=. ./...
