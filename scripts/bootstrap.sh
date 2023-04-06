#!/usr/bin/env bash

set -euo pipefail

################################################################################
# GLOBAL VARIABLES
################################################################################

export AWS_PAGER="cat"

# Colors
declare -r CYAN="\e[1;36m"
declare -r GREEN="\e[1;32m"
declare -r RED="\e[1;31m"
declare -r RESET="\e[0m"
declare -r YELLOW="\e[1;33m"
declare -r WHITE="\e[1;37m"

################################################################################
# ARGUMENTS
################################################################################

# The name of the AWS region to deploy the Terraform backend infrastructure into
declare AWS_REGION
# The name of the AWS DynamoDB table to use to store the Terraform state lock
declare AWS_DYNAMODB_TABLE_NAME
# The name of the AWS S3 bucket to use to store the Terraform state
declare AWS_S3_BUCKET_NAME

function usage() {
  cat <<EOF
Bootstraps the required infrastructure to allow Terraform to manage its state in AWS.

Usage:
  ./bootstrap.sh --bucket <string> --region <string> --table <string>

Options:
  --bucket    The name of the AWS S3 bucket to use to store the Terraform state.
  --region    The name of the AWS region to deploy the Terraform backend infrastructure into.
  --table     The name of the AWS DynamoDB table to use to store the Terraform state lock.
EOF
}

function info() {
  printf "${WHITE}%(%Y-%m-%d %H:%M:%S)T${RESET}\t%b\n" -1 "$*"
}

function error() {
  info "${RED}${1}${RESET}"
}

function parse_arguments() {
  while [[ $# -gt 0 ]]; do
    case "${1}" in
      --bucket)
        AWS_S3_BUCKET_NAME="${2}"
        shift 2
        ;;

      --region)
        AWS_REGION="${2}"
        shift 2
        ;;

      --table)
        AWS_DYNAMODB_TABLE_NAME="${2}"
        shift 2
        ;;

      *)
        error "[ERROR]: unknown command line argument - '${1}'"
        ;;
    esac
  done
}

function validate_arguments() {
  if [[ ! -v AWS_S3_BUCKET_NAME ]]; then
    error "[ERROR]: Must provide the '--bucket' argument\n"
    usage
    exit 1
  fi

  if [[ ! -v AWS_REGION ]]; then
    error "[ERROR]: Must provide the '--region' argument\n"
    usage
    exit 1
  fi

  if [[ ! -v AWS_DYNAMODB_TABLE_NAME ]]; then
    error "[ERROR]: Must provide the '--table' argument\n"
    usage
    exit 1
  fi
}

function validate_authentication() {
  if ! aws sts get-caller-identity > /dev/null 2>&1; then
    error "[ERROR]: Must authenticate with AWS"
  fi
}

function create_s3_bucket() {
  local bucket="${1}"
  local region="${2}"
  aws s3api create-bucket \
    --bucket "${bucket}" \
    --region "${region}" \
    --create-bucket-configuration "{
      \"LocationConstraint\": \"${region}\"
    }"
}

function enable_s3_bucket_versioning() {
  local bucket="${1}"
  local region="${2}"
  aws s3api put-bucket-versioning \
    --bucket "${bucket}" \
    --region "${region}" \
    --versioning-configuration '{
      "Status": "Enabled"
    }'
}

function enable_s3_bucket_encryption() {
  local bucket="${1}"
  local region="${2}"
  aws s3api put-bucket-encryption \
    --bucket "${bucket}" \
    --region "${region}" \
    --server-side-encryption-configuration '{
      "Rules": [
        {
          "ApplyServerSideEncryptionByDefault": {
            "SSEAlgorithm": "AES256"
          }
        }
      ]
    }'
}

function disable_s3_bucket_public_access() {
  local bucket="${1}"
  local region="${2}"
  aws s3api put-public-access-block \
    --bucket "${bucket}" \
    --region "${region}" \
    --public-access-block-configuration '{
      "BlockPublicAcls": true,
      "IgnorePublicAcls": true,
      "BlockPublicPolicy": true,
      "RestrictPublicBuckets": true
    }'
}

function create_dynamodb_table() {
  local table="${1}"
  local region="${2}"
  aws dynamodb create-table \
    --table-name "${table}" \
    --region "${region}" \
    --billing-mode PROVISIONED \
    --attribute-definitions '[{"AttributeName":"LockID","AttributeType":"S"}]' \
    --key-schema '[{"AttributeName":"LockID","KeyType":"HASH"}]' \
    --provisioned-throughput '{"ReadCapacityUnits":5,"WriteCapacityUnits":5}'
}

function main() {
  parse_arguments "$@"
  validate_arguments
  validate_authentication
  local bucket="${AWS_S3_BUCKET_NAME}"
  local region="${AWS_REGION}"
  local table="${AWS_DYNAMODB_TABLE_NAME}"
  info "${YELLOW}Provisioning the required Terraform backend infrastructure - this may take some time...${RESET}"
  info "${CYAN}Creating AWS S3 bucket with name=\"${bucket}\" and region=\"${region}\"...${RESET}"
  create_s3_bucket "${bucket}" "${region}"
  info "${CYAN}Enabling AWS S3 bucket versioning for bucket=\"${bucket}\"${RESET}"
  enable_s3_bucket_versioning "${bucket}" "${region}"
  info "${CYAN}Enabling AWS S3 bucket encryption for bucket=\"${bucket}\"${RESET}"
  enable_s3_bucket_encryption "${bucket}" "${region}"
  info "${CYAN}Disabling AWS S3 bucket public access for bucket=\"${bucket}\"${RESET}"
  disable_s3_bucket_public_access "${bucket}" "${region}"
  info "${CYAN}Creating AWS DynamoDB table with name=\"${table}\" and region=\"${region}\"${RESET}"
  create_dynamodb_table "${table}" "${region}"
  info "${GREEN}Successfully provisioned the requested Terraform backend infrastructure!${RESET}"
}

main "$@"
