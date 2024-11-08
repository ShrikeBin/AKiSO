#!/bin/bash

# Fetch a random cat image URL from The Cat API
cat_image_url=$(curl -s https://api.thecatapi.com/v1/images/search | jq -r '.[0].url')

# Ensure the URL is valid
if [[ -z "$cat_image_url" ]]; then
    echo "Failed to fetch a cat image URL."
    exit 1
fi

curl -s "$cat_image_url" | catimg -

quote=$(curl -s https://api.chucknorris.io/jokes/random | jq -r '.value')

echo -e "\n$quote"
