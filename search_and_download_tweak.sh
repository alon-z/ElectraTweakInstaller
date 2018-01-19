#!/bin/bash
TWEAKS=$(curl --silent https://sheets.googleapis.com/v4/spreadsheets/1YptWW_bBdEQ9naYAfiZ2Aj4H93Y56I4xSYI29u4q_-Y/values/A21:A?key=AIzaSyDig3bllvpnIql6jhjvvVQ5J4672DUsMdI)
LINE=$(echo "$TWEAKS" | grep -ni $1)
if [ "$LINE" ]; then
LINE=$(echo "$LINE" | awk '{ print $1 }' | sed 's@:@@')
LINE=$((($LINE-5)/3+22))
STATUS=$(curl --silent https://sheets.googleapis.com/v4/spreadsheets/1YptWW_bBdEQ9naYAfiZ2Aj4H93Y56I4xSYI29u4q_-Y/values/A$LINE:C$LINE?key=AIzaSyDig3bllvpnIql6jhjvvVQ5J4672DUsMdI | grep -v \"values\" | grep "\[" -A 3 | tail -n 3 | sed 's@[",]@@g' | sed 's@[ ]*@@')
TWEAK_NAME=$(echo "$STATUS" | head -n 1)
TWEAK_DESC=$(echo "$STATUS" | head -n 2 | tail -n 1)
TWEAK_STATUS=$(echo "$STATUS" | tail -n 1)
echo "Tweak name: $TWEAK_NAME"
echo "Status: $TWEAK_STATUS"
echo "Description: $TWEAK_DESC"
else
echo "Not found on electra sheet (reddit)"
echo "Do you still want to search on cydiaupdates for deb?"
read -p 'Y for yes: ' answer
if [[ "$answer" != Y ]]; then
exit
fi
fi
if [ -z "$TWEAK_NAME" ]; then
TWEAK_NAME=$1
fi
CYDIA_UPDATES=$(curl --silent "https://www.cydiaupdates.org/search/?s=$TWEAK_NAME&section=all&repo=all" | grep pack)
CYDIA_UPDATES=$( echo "$CYDIA_UPDATES" | grep -i $TWEAK_NAME)
if [ -z "$CYDIA_UPDATES" ]; then
echo "Tweak not found on cydia updates"
exit
fi
TWEAK_VERSION=$(echo "$CYDIA_UPDATES" | awk '{ print $4 }' | sed 's@<small>@@' | sed 's@</.*@@')
echo Version: $TWEAK_VERSION
#https://www.cydiaupdates.org/pack/152802/
PACK=$(echo "$CYDIA_UPDATES" | awk '{ print $3 }' | sed 's@.*\"/@@' | sed 's@\".*@@')
DEB=$(curl --silent "https://www.cydiaupdates.org/$PACK" | grep deb | grep -v \<meta | head -n 1 | sed 's@.*href=\"@@' | sed 's@\">.*@@')
curl --silent "$DEB" > "$( echo $DEB | sed 's@.*/@@' )"
