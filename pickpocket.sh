#!/usr/bin/env bash
#
# Pick items in your Pocket
#
#/ Usage:
#/   ./pickpocket.sh <cookie_db>
#/
#/ Options:
#/    <cookie_db>     required, path to cookie db
#/    --help          display this help message

set -e
set -u

usage() {
    printf "%b\n" "$(grep '^#/' "$0" | cut -c4-)" >&2 && exit 1
}

set_var() {
    _SCRIPT_PATH=$(dirname "$0")
    _CONFIG_FILE="$_SCRIPT_PATH/match.conf"
    _DECRYPT_CHROMIUM_COOKIE_SCRIPT="$_SCRIPT_PATH/bin/decryptCookies.py"
    _COOKIE=$(get_cookie "$_DB_PATH")
    source "$_SCRIPT_PATH/lib/pocket-api-call.sh"
    source "$_SCRIPT_PATH/custom-func.sh"
}

set_command() {
    _SQLITE="$(command -v sqlite3)" || command_not_found "sqlite3" "https://sqlite.org/download.html"
    _JQ="$(command -v jq)" || command_not_found "jq" "https://stedolan.github.io/jq/download/"
}

set_args() {
    expr "$*" : ".*--help" > /dev/null && usage
    _DB_PATH="${1:-}"
}

print_info() {
    # $1: info message
    printf "%b\n" "\033[32m[INFO]\033[0m $1" >&2
}

print_error() {
    # $1: error message
    printf "%b\n" "\033[31m[ERROR]\033[0m $1" >&2
    exit 1
}

command_not_found() {
    # $1: command name
    # $2: installation URL
    if [[ -n "${2:-}" ]]; then
        print_error "$1 command not found! Install from $2"
    else
        print_error "$1 command not found!"
    fi
}

check_args() {
    if [[ -z "${_DB_PATH:-}" ]]; then
        echo '<cookie_db> is missing!' && usage
    fi
}

get_cookie() {
    # $1: cookie db path
    [[ ! -f "$1" ]] && print_error "cookie db file '$1' doesn't exist!"

    local t tmp
    tmp=$(mktemp)
    cp "$1" "$tmp"

    t=$($_SQLITE "$tmp" ".tables")
    if [[ "$t" == "moz_cookies" ]]; then
        $_SQLITE "$tmp" "SELECT name,value from moz_cookies where host='getpocket.com'" \
            | awk '{printf "%s; ", $0}' \
            | sed -E 's/\|/\=/g'
    elif [[ "$t" =~ "cookies"* ]]; then
        $_DECRYPT_CHROMIUM_COOKIE_SCRIPT "$1" | awk '{printf "%s",$0}'
    else
        print_error "Cannot find right table in ${1}!"
    fi

    rm -f "$tmp"
}

filter_item() {
    # $1: config file
    # $2: json data from retrieve_pocket_item
    local len list item opt match func val
    len=$($_JQ -r '.list | length' <<< "$2")
    list=$($_JQ -r '.list[]' <<< "$2" | $_JQ -s)
    for (( i = 0; i < len; i++ )); do
        item=$($_JQ -r '.[$index | tonumber]' --arg index "$i" <<< "$list")
        while read -r line; do
            opt=$(awk '{print $1}' <<< "$line")
            match=$(awk '{print $2}' <<< "$line")
            func=$(awk '{print $3}' <<< "$line")
            val=$($_JQ -r '.[$node]' --arg node "$opt" <<< "$item")
            if [[ "$val" =~ $match ]]; then
                print_info "Find match $opt $match"
                "$func" "$item"
            fi
        done < "$1"
    done
}

main() {
    set_args "$@"
    check_args
    set_command
    set_var

    local data
    data=$(retrieve_pocket_item)
    filter_item "$_CONFIG_FILE" "$data"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
