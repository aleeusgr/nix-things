#!/bin/sh

# genpass.sh — password generator
# Usage: ./genpass.sh [-s] [-n COUNT] [-l LENGTH]
#   -s          include special characters (!@#$%+-_)
#   -n COUNT    number of passwords to generate (default: 1)
#   -l LENGTH   password length (default: 28)

set -euo pipefail

SPECIAL=false
COUNT=1
LENGTH=16

usage() {
    grep '^#' "$0" | grep -v '^#!/' | sed 's/^# \?//'
    exit 0
}

while getopts ":sn:l:h" opt; do
    case $opt in
        s) SPECIAL=true ;;
        n) COUNT="$OPTARG" ;;
        l) LENGTH="$OPTARG" ;;
        h) usage ;;
        :) echo "Error: -$OPTARG requires an argument" >&2; exit 1 ;;
        \?) echo "Error: unknown flag -$OPTARG" >&2; exit 1 ;;
    esac
done

if $SPECIAL; then
    CHARSET='a-zA-Z0-9-_!@#$%+'
else
    CHARSET='a-zA-Z0-9'
fi

LC_ALL=C tr -dc "$CHARSET" < /dev/urandom \
    | fold -w "$LENGTH" \
    | head -n "$COUNT"
