#!/bin/bash

source const.sh


# Your JSON file path

update_chain() {
    local json_file= $1
    local key="$2"
    local value="$3"
    jq --arg key "$key" --arg value "$value" \
       '.[$key] = $value' "$json_file" > "$json_file.tmp" && mv "$json_file.tmp" "$json_file"
}

# Example usage
update_json "ram" "new_value1"
update_json "key2" "new_value2"


