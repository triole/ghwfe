#!/bin/bash

[[ -z "${GOROOT}" ]] && export GOROOT="/usr/local/bin"

source_folder="${SOURCE_FOLDER}"
[[ -z "${source_folder}" ]] && source_folder="${GITHUB_WORKSPACE}"

source_folder="$(realpath "${source_folder}")"

target_folder="${TARGET_FOLDER}"
[[ -z "${target_folder}" ]] && target_folder="/tmp/assets"

target_folder="$(realpath "${target_folder}")"

mkdir -p "${target_folder}"

result="$(mktemp)"
gobin="${GOROOT}/bin/go"

echo -e "\nRun tests"
${gobin} test -v -race -cover -bench=. ./...
