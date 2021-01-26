#!/bin/bash

set -euo pipefail

: "${DbHostname=""}"
: "${DbUser=""}"
: "${DbPassword=""}"
: "${DbName=""}"
: "${S3AccessKey=""}"
: "${S3SecretKey=""}"
: "${S3Bucket=""}"

function waitForDBMS {
  until mongo --host "$DbHostname" --username "$DbUser" --password "$DbPassword" "$DbName" --eval "print(\"waited for connection\")"
  do
    sleep 60
  done
}

setupEnv() {
  if [[ -z "${DB_HOSTNAME}" ]]; then
      echo "DB_HOSTNAME variable not exists"
      exit 1
  else
      DbHostname="${DB_HOSTNAME}"
  fi
  if [[ -z "${DB_USER}" ]]; then
      echo "DB_USER variable not exists"
      exit 1
  else
      DbUser="${DB_USER}"
  fi
  if [[ -z "${DB_PASSWORD}" ]]; then
      echo "DB_PASSWORD variable not exists"
      exit 1
  else
      DbPassword="${DB_PASSWORD}"
  fi
  if [[ -z "${DB_NAME}" ]]; then
      echo "DB_NAME variable not exists"
      exit 1
  else
      DbName="${DB_NAME}"
  fi
  if [[ -z "${S3_ACCESS_KEY}" ]]; then
      echo "S3_ACCESS_KEY variable not exists"
      exit 1
  else
      S3AccessKey="${S3_ACCESS_KEY}"
  fi
  if [[ -z "${S3_SECRET_KEY}" ]]; then
      echo "S3_SECRET_KEY variable not exists"
      exit 1
  else
      S3SecretKey="${S3_SECRET_KEY}"
  fi
  if [[ -z "${S3_BUCKET}" ]]; then
      echo "S3_BUCKET variable not exists"
      exit 1
  else
      S3Bucket="${S3_BUCKET}"
  fi
}

function log {
  echo -e "$1" 1>&2
}

backupToFile() {
  cd "$HOME"
  DEST="$HOME/tmp"
  TIME=`/bin/date +%d-%m-%Y-%T`
  TAR="$DEST/../$TIME.tar"
  ENDPOINT="s3://$S3Bucket/"
  mkdir -p "$DEST"
  mongodump --db "$DbName" --host "$DbHostname" --username "$DbUser" --password "$DbPassword" --gzip -o "$DEST"
  tar cvf "$TAR" -C "$DEST" .
  /usr/local/bin/s3cmd/s3cmd put "$TAR" "$ENDPOINT" --access_key "$S3AccessKey" --secret_key "$S3SecretKey"
  rm "$TAR"
  rm -rf "$DEST"
}

_main() {
  setupEnv
  waitForDBMS
  backupToFile
}

_main "$@"