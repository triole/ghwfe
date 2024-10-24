#!/bin/bash

source_folder="${SOURCE_FOLDER}"
if [[ -z "${source_folder}" ]]; then
  source_folder="${GITHUB_WORKSPACE}"
fi
source_folder="$(realpath "${source_folder}")"

target_folder="${TARGET_FOLDER}"
if [[ -z "${target_folder}" ]]; then
  target_folder="/tmp/assets"
fi
target_folder="$(realpath "${target_folder}")"

mkdir -p "${target_folder}"

result="$(mktemp)"
gobin="${GOROOT}/bin/go"

echo -e "\nRun tests"
${gobin} test ./... -v -coverpkg=./... -race -bench=.
