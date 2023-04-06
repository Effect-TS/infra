#!/usr/bin/env bash

set -euo pipefail

################################################################################
# GLOBAL VARIABLES
################################################################################

# Colors
declare -r CYAN="\e[1;36m"
declare -r GREEN="\e[1;32m"
declare -r RED="\e[1;31m"
declare -r RESET="\e[0m"
declare -r WHITE="\e[1;37m"

################################################################################
# ARGUMENTS
################################################################################

# The subcommand that should be executed
declare SUBCOMMAND
# The username to give to the user in Kubernetes
declare USERNAME
# The email of the user which will be used as the FQDN in the certificate signing request
declare EMAIL
# The group that will be used as the organization name in the certificate signing request.
declare GROUP
# The number of milliseconds before the certificate signing request expires
declare EXPIRATION="86400"

function usage() {
  cat <<EOF
Generates a new certificate signing request or downloads an accepted certificate signing request.

Usage:
  ./csr.sh generate --username <string> --email <string> --group <string> [--expiration <milliseconds>]
  ./csr.sh download --username <string>

Options:
  --username      The username to give to the user in Kubernetes.
  --email         The email of the user which will be used as the FQDN in the certificate signing request.
  --group         The group that will be used as the organization name in the certificate signing request.
  --expiration    The number of milliseconds before the certificate signing request expires (default: 86400).
EOF
}

function info() {
  printf "${WHITE}%(%Y-%m-%d %H:%M:%S)T${RESET}\t%b\n" -1 "$*"
}

function error() {
  info "${RED}${1}${RESET}"
}

function parse_subcommand() {
  case "${1}" in
    generate|download)
      SUBCOMMAND="${1}"
      ;;

    *)
      error "[ERROR]: unknown subcommand - '${1}'"
      usage
      exit 1
      ;;
  esac
}

function parse_arguments() {
  local subcommand="${1}"
  case "${subcommand}" in
    generate)
      parse_generate_subcommand "${@:2}"
      ;;

    download)
      parse_download_subcommand "${@:2}"
      ;;
  esac
}

function parse_generate_subcommand() {
  while [[ $# -gt 0 ]]; do
    case "${1}" in
      --username)
        USERNAME="${2}"
        shift 2
        ;;

      --email)
        EMAIL="${2}"
        shift 2
        ;;

      --group)
        GROUP="${2}"
        shift 2
        ;;

      --expiration)
        EXPIRATION="${2}"
        shift 2
        ;;

      *)
        error "[ERROR]: unknown command line argument - '${1}'"
        ;;
    esac
  done
}

function parse_download_subcommand() {
  while [[ $# -gt 0 ]]; do
    case "${1}" in
      --username)
        USERNAME="${2}"
        shift 2
        ;;

      *)
        error "[ERROR]: unknown command line argument - '${1}'"
        ;;
    esac
  done
}

function validate_arguments() {
   local subcommand="${1}"
  case "${subcommand}" in
    generate)
      validate_generate_subcommand
      ;;

    download)
      validate_download_subcommand
      ;;
  esac
}

function validate_generate_subcommand() {
  if [[ ! -v USERNAME ]]; then
    error "[ERROR]: Must provide the '--username' argument\n"
    usage
    exit 1
  fi

  if [[ ! -v EMAIL ]]; then
    error "[ERROR]: Must provide the '--username' argument\n"
    usage
    exit 1
  fi

  if [[ ! -v GROUP ]]; then
    error "[ERROR]: Must provide the '--username' argument\n"
    usage
    exit 1
  fi
}

function validate_download_subcommand() {
  if [[ ! -v USERNAME ]]; then
    error "[ERROR]: Must provide the '--username' argument\n"
    usage
    exit 1
  fi
}

function generate_csr_config() {
  local username="${1}"
  local email="${2}"
  local group="${3}"
  cat <<EOF > "${username}.csr.cnf"
[ req ]
default_bits = 4096
prompt = no
default_md = sha256
distinguished_name = dn
[ dn ]
CN = ${email}
O = ${group}
[ v3_ext ]
authorityKeyIdentifier=keyid,issuer:always
basicConstraints=CA:FALSE
keyUsage=keyEncipherment,dataEncipherment
extendedKeyUsage=serverAuth,clientAuth
EOF
}

function generate_private_key() {
  local username="${1}"
  openssl genrsa -out "${username}.key" 4096
}

function generate_public_csr() {
  local username="${1}"
  openssl req -config "${username}.csr.cnf" -new -key "${username}.key" -nodes -out "${username}.csr"
}

function generate_certificate_signing_request() {
  local username="${1}"
  local expiration="${2}"
  cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: ${username}-authentication
spec:
  groups:
    - system:authenticated
  request: $(cat "${username}.csr" | base64 | tr -d "\n")
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: ${expiration}
  usages:
    - client auth
EOF
}

function download_approved_certificate() {
  local username="${1}"
  kubectl get csr "${username}-authentication" -o jsonpath='{.status.certificate}' | \
  base64 --decode > "${username}.crt"
}

function main() {
  parse_subcommand "${1}"
  parse_arguments "${SUBCOMMAND}" "${@:2}"
  validate_arguments "${SUBCOMMAND}"
  case "${SUBCOMMAND}" in
    generate)
      info "${WHITE}Creating a new certificate signing request...${RESET}"
      info "${CYAN}Generating certificate signing request configuration${RESET}"
      generate_csr_config "${USERNAME}" "${EMAIL}" "${GROUP}"
      info "${CYAN}Generating certificate signing request private key${RESET}"
      generate_private_key "${USERNAME}"
      info "${CYAN}Generating certificate signing request${RESET}"
      generate_public_csr "${USERNAME}"
      info "${CYAN}Deploying certificate signing request...${RESET}"
      generate_certificate_signing_request "${USERNAME}" "${EXPIRATION}"
      info "${GREEN}Successfully deployed certificate signing request!${RESET}"
      ;;

    download)
      info "${WHITE}Downloading approved certificate...${RESET}"
      download_approved_certificate "${USERNAME}"
      info "${GREEN}Successfully downloaded certificate to $(pwd)/${USERNAME}.crt${RESET}"
      ;;
  esac
}

main "$@"
