#!/usr/bin/env bash
set -e

# from https://github.com/terraform-providers/terraform-provider-archive/issues/10#issuecomment-365979047

if [[ "$1" != "" ]]; then
    DIR="$1"
else
    DIR=.
fi

ZIP_PATH=".output/deployment_package.zip"

# make sure you have the `-q` flag to not mess with the output JSON
zip -jq "${DIR}/${ZIP_PATH}" ${DIR}/sources/*
BASE_64_SHA256=$(shasum -a 256 -p ${DIR}/your_zip | base64)
echo "{ \"source_hash\": \"${BASE_64_SHA256}\", \"zip_path\": \"${ZIP_PATH}\" }"
