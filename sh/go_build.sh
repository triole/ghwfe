#!/bin/bash
IFS=$'\n'
architectures=(
  "darwin_arm64:GOOS=darwin GOARCH=arm64"
  "darwin_x86_64:GOOS=darwin GOARCH=amd64"
  "freebsd_arm64:GOOS=freebsd GOARCH=arm64"
  "freebsd_i386:GOOS=freebsd GOARCH=386"
  "freebsd_x86_64:GOOS=freebsd GOARCH=amd64"
  "linux_armv5l:GOOS=linux GOARCH=arm GOARM=5"
  "linux_armv6l:GOOS=linux GOARCH=arm GOARM=6"
  "linux_armv7l:GOOS=linux GOARCH=arm GOARM=7"
  "linux_armv64:GOOS=linux GOARCH=arm64"
  "linux_i386:GOOS=linux GOARCH=386"
  "linux_x86_64:GOOS=linux GOARCH=amd64"
  "windows_i386:GOOS=windows GOARCH=386"
  "windows_x86_64:GOOS=windows GOARCH=amd64"
  "windows_arm64:GOOS=windows GOARCH=arm64"
)

app_name="${APP_NAME}"
if [[ -z "${app_name}" ]]; then
  app_name=$(pwd | grep -Po "[^/]+$")
fi
ld_author=$(grep -Po "(?<=name\s=\s).*" ~/.gitconfig)
ld_git_commit_no=$(git rev-list "origin/master" --count --all)
ld_git_commit_hash=$(git rev-parse HEAD)
ld_date=$(LANG=en_us_88591 date)

source_folder="${SOURCE_FOLDER}"
if [[ -z "${source_folder}" ]]; then
  source_folder="${GITHUB_WORKSPACE}"
fi
source_folder="$(realpath "${source_folder}")"

target_folder="${TARGET_FOLDER}"
if [[ -z "${target_folder}" ]]; then
  target_folder="build"
fi
target_folder="$(realpath "${target_folder}")"

gobin="${GOROOT}/bin/go"
goversion="$(${gobin} version | grep -Po "(?<=go)[0-9\.]+")"

debug="false"
for val in "$@"; do
  if [[ "${val}" =~ ^-+(d|debug)$ ]]; then
    debug="true"
  fi
done

rcmd() {
  cmd="$(echo ${1} | tr -d '\n' | sed 's/  \+/ /g')"
  echo -e "\n\033[0;93m${cmd}\033[0m"
  if [[ "${debug}" == "false" ]]; then
    eval ${cmd}
  fi
}

update_modules() {
  subfol_src="$(echo "${SOURCE_FOLDER}" | grep -Poc "src(/)?$")"
  if [[ "${subfol_src}" == "1" ]]; then
    cd ..
  fi
  rcmd "${gobin} mod init ${app_name}"
  rcmd "${gobin} mod tidy"
}

cd "${source_folder}"
update_modules
cd "${source_folder}"

echo -e "\nSource folder \"$(pwd)\" layout:"
ls
echo ""

if [[ -n "${PRE_BUILD_COMMANDS}" ]]; then
  echo -e "\nGot pre build commands. Execute..."
  for cmd in $(echo ${PRE_BUILD_COMMANDS[@]} | tr ';' '\n'); do
    rcmd "${cmd}"
  done
fi

for arch in "${architectures[@]}"; do
  arch_name="$(echo "${arch}" | grep -Po ".*(?=:)" | sed "s|armv|arm|g")"
  arch="$(echo "${arch}" | grep -Po "[^:]+$")"
  rcmd "CGO_ENABLED=0 ${arch} ${gobin} build ${BUILD_ARGS} \
        -o ${target_folder}/${arch_name}/${app_name} \
        -ldflags \
        \"-s -w -X 'main.BUILDTAGS={
            _subversion: ${ld_git_commit_no}, author: ${ld_author},
            build date: ${ld_date}, git hash: ${ld_git_commit_hash},
            go version: ${goversion}
        }'\""
done

find "$(realpath ${target_folder})" -type f -executable \
  -exec echo '' \; \
  -exec md5sum {} \; \
  -exec file {} \;
