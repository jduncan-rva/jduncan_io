#! /usr/bin/env bash

ARTICLE=$1

echo "Creating new blog post $1."
hugo new blog/$1.md
echo "Creating directory for images."
mkdir -p static/images/$1
echo "Done. Happy writing."