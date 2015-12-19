#!/bin/bash
PROCESSING_DIR=/home/pi/processing-3.0.1
QUEERBOT_DIR=/home/pi/queerbot
GIT_HASH=$(git --git-dir=$QUEERBOT_DIR/.git rev-parse --short HEAD)
echo
echo
echo
toilet -f big -F gay "        queerbot"
echo
echo -e "\trevision $GIT_HASH"
echo
echo -e "\tStarting..."
export QUEERBOT_REVISION=$GIT_HASH
export DISPLAY=:0
$PROCESSING_DIR/processing-java --sketch=$QUEERBOT_DIR --run >> $QUEERBOT_DIR/log/out.log 2>&1
