#!/bin/bash

set -e




cd /home/wolos/amper_bot

git fetch origin main

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)

if [ "$LOCAL" = "$REMOTE" ]; then
    echo "nic nowego"
    exit 0
else
    echo "ściągam updaty"

    git pull origin main

    docker rm -f amper_bot_app || true
    docker build -t amper_bot_img .
    docker run -d --name amper_bot_app --restart unless-stopped --env-file .env amper_bot_img

    echo "bot działa"
fi
