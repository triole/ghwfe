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

result="$(mktemp)"
gobin="${GOROOT}/bin/go"

function download_badge() {
    echo "Save coverage badge to ${4}"
    curl -sS "https://img.shields.io/badge/${1}-${2}-${3}" >"${4}"
}

echo -e "\nRun tests"
cd "${source_folder}" && ${gobin} test -trace go.trace -race -cover -bench=. |
    tee "${result}"

if [[ "${MAKE_BADGES}" == "true" ]]; then
    echo -e "\nMake badges"
    if [[ -f "${result}" ]]; then
        coverage_value=$(cat "${result}" | grep -Po "[0-9\.]+(?=%)" | head -n 1)
        if [[ -n "${coverage_value}" ]]; then
            tests_status=$(
                cat "${result}" | grep -Po "PASS" | head -n 1 | tr '[:upper:]' '[:lower:]'
            )
            if [[ -z "${tests_status}" ]]; then
                tests_status="fail"
            fi
            tests_colour="red"
            if [[ "${tests_status}" == "pass" ]]; then
                tests_colour="brightgreen"
            fi
            coverage_colour="lightgrey"
            if (($(echo "${coverage_value} <= 50" | bc -l))); then
                coverage_colour="red"
            elif (($(echo "${coverage_value} <= 80" | bc -l))); then
                coverage_colour="yellow"
            elif (($(echo "${coverage_value} <= 90" | bc -l))); then
                coverage_colour="green"
            else
                coverage_colour="brightgreen"
            fi
        fi
    fi

    download_badge "coverage" "${coverage_value}%25" "${coverage_colour}" \
        "${target_folder}/_badge_coverage.svg"

    download_badge "tests" "${tests_status}" "${tests_colour}" \
        "${target_folder}/_badge_tests.svg"
fi
