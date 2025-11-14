#!/bin/bash

goroot="/usr/local"
[[ -n "${GOROOT}" ]] && goroot="${goroot}"

export GOROOT="${goroot}"

source_folder="${SOURCE_FOLDER}"
[[ -z "${source_folder}" ]] && source_folder="${GITHUB_WORKSPACE}"

source_folder="$(realpath "${source_folder}")"

target_folder="${TARGET_FOLDER}"
[[ -z "${target_folder}" ]] && target_folder="/tmp/assets"

target_folder="$(realpath "${target_folder}")"

mkdir -p "${target_folder}"

echo -e "run tests"
go test -v -race -cover -bench=. ./...
