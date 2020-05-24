#!/usr/bin/env bash

set -e
set -u

_CURL="$(command -v curl)" || command_not_found "curl" "https://curl.haxx.se/download.html"
_HOST="https://getpocket.com/v3"
# Get key from https://app.getpocket.com/static/js/main.c9945b96.chunk.js.map
_CONSUMER_KEY="78809-9423d8c743a58f62b23ee85c"

retrieve_pocket_item() {
    $_CURL -sS "$_HOST/get?enable_cors=1&consumer_key=$_CONSUMER_KEY" \
        -H 'Origin: https://app.getpocket.com' \
        -H 'Content-type: application/json' \
        -H "Cookie: $_COOKIE" \
        --data-raw '{"images":1,"videos":1,"tags":1,"rediscovery":1,"annotations":1,"authors":1,"itemTopics":1,"meta":1,"posts":1,"total":1,"state":"unread","offset":0,"sort":"newest","count":999,"forceaccount":1,"locale_lang":"en-US"}'
}

delete_pocket_item() {
    # $1: item id
    $_CURL -sS "$_HOST/send?enable_cors=1&consumer_key=$_CONSUMER_KEY" \
        -H 'Origin: https://app.getpocket.com' \
        -H 'Content-type: application/json' \
        -H "Cookie: $_COOKIE" \
        --data-raw '{"actions":[{"action":"delete","item_id":"'"$1"'","cxt_ui":"item_menu","cxt_view":"list","cxt_list_view":"list","cxt_index":0}],"locale_lang":"en-US"}'
    echo ""
}

archive_pocket_item() {
    # $1: item id
    $_CURL -sS "$_HOST/send?enable_cors=1&consumer_key=$_CONSUMER_KEY" \
        -H 'Origin: https://app.getpocket.com' \
        -H 'Content-type: application/json' \
        -H "Cookie: $_COOKIE" \
        --data-raw '{"actions":[{"action":"archive","item_id":"'"$1"'","cxt_ui":"item_menu","cxt_view":"list","cxt_list_view":"list","cxt_index":0}],"locale_lang":"en-US"}'
    echo ""
}
