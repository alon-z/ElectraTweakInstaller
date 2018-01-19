#!/bin/bash
TWEAKS=$(curl --silent https://sheets.googleapis.com/v4/spreadsheets/1YptWW_bBdEQ9naYAfiZ2Aj4H93Y56I4xSYI29u4q_-Y/values/A21:A?key=AIzaSyDig3bllvpnIql6jhjvvVQ5J4672DUsMdI)
AMOUNT=$(echo "$TWEAKS" | wc -l)
LINE=$(echo "$TWEAKS" | grep -ni $1 | awk '{ print $1 }' | sed 's@:@@')
LINE=$((($LINE-5)/3+22))
STATUS=$(curl --silent https://sheets.googleapis.com/v4/spreadsheets/1YptWW_bBdEQ9naYAfiZ2Aj4H93Y56I4xSYI29u4q_-Y/values/A$LINE:C$LINE?key=AIzaSyDig3bllvpnIql6jhjvvVQ5J4672DUsMdI | grep -v \"values\" | grep "\[" -A 3 | tail -n 3 | sed 's@[",]@@g' | sed 's@[ ]*@@')
TWEAK_NAME=$(echo "$STATUS" | head -n 1)
TWEAK_DESC=$(echo "$STATUS" | head -n 2 | tail -n 1)
TWEAK_STATUS=$(echo "$STATUS" | tail -n 1)
echo "Tweak name: $TWEAK_NAME"
echo "Status: $TWEAK_STATUS"
echo "Description: $TWEAK_DESC"
CYDIA_UPDATES=$(curl --silent "https://www.cydiaupdates.org/search/?s=$TWEAK_NAME&section=all&repo=all" | grep pack | grep -i $TWEAK_NAME)
TWEAK_VERSION=$(echo "$CYDIA_UPDATES" | awk '{ print $4 }' | sed 's@<small>@@' | sed 's@</.*@@')
echo Version: $TWEAK_VERSION
#https://www.cydiaupdates.org/pack/152802/
PACK=$(echo "$CYDIA_UPDATES" | awk '{ print $3 }' | sed 's@.*\"/@@' | sed 's@\".*@@')
DEB=$(curl --silent "https://www.cydiaupdates.org/$PACK" | grep deb | grep -v \<meta | head -n 1 | sed 's@.*href=\"@@' | sed 's@\">.*@@')
curl --silent "$DEB" > "$( echo $DEB | sed 's@.*/@@' )"
