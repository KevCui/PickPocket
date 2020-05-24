#!/usr/bin/env bash

download_video() {
    local id link
    id=$($_JQ -r '.item_id' <<< "$@")
    link=$($_JQ -r '.resolved_url' <<< "$@")

    print_info "  Download video: $link"
    youtube-dl "$link"

    print_info "  Removing item from list: $id"
    delete_pocket_item "$id"
}

open_in_browser() {
    local id link
    id=$($_JQ -r '.item_id' <<< "$@")
    link=$($_JQ -r '.resolved_url' <<< "$@")
    print_info "  Open link in browser: $link"
    xdg-open "$link"
}

archive_item() {
    local id
    id=$($_JQ -r '.item_id' <<< "$@")
    print_info "  Archiving item: $id"
    archive_pocket_item "$id"
}
