#!/bin/bash

# Fetch a random cat image URL from The Cat API
cat_image_url=$(curl -s https://api.thecatapi.com/v1/images/search | jq -r '.[0].url')

# Ensure the URL is valid
if [[ -z "$cat_image_url" ]]; then
    echo "Failed to fetch a cat image URL."
    exit 1
fi

temp_image=$(mktemp /tmp/cat_image.XXXXXX)

curl -s "$cat_image_url" -o "$temp_image"

catimg "$temp_image"

quote=$(curl -s https://api.chucknorris.io/jokes/random | jq -r '.value')

echo -e "\n$quote"

rm -f "$temp_image"
