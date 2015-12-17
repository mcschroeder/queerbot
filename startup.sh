#!/bin/bash
PROCESSING_DIR=/home/pi/processing-3.0.1
QUEERBOT_DIR=/home/pi/queerbot
GIT_HASH=$(git --git-dir=$QUEERBOT_DIR/.git rev-parse --short HEAD)
toilet -f big -F gay "queerbot"
echo
echo "revision $GIT_HASH"
echo
echo "Starting..."
export QUEERBOT_REVISION=$GIT_HASH
export DISPLAY=:0
$PROCESSING_DIR/processing-java --sketch=$QUEERBOT_DIR --run
