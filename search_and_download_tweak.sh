#!/bin/bash
TWEAKS=$(curl --silent https://sheets.googleapis.com/v4/spreadsheets/1YptWW_bBdEQ9naYAfiZ2Aj4H93Y56I4xSYI29u4q_-Y/values/A21:A?key=AIzaSyDig3bllvpnIql6jhjvvVQ5J4672DUsMdI)
LINE=$(echo "$TWEAKS" | grep -ni $1)
NUM_LINES=$(echo "LINE" | wc -l)
if [[ "$NUM_LINES" != 1 ]]; then
  echo "Found more than one resault: "
  echo "$LINE"
  exit
fi
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
if [[ "$TWEAK_STATUS" != "Stable/Works" ]]; then
  echo "The tweak status is not stable, are you sure you would like to install?"
  read -p 'Y for yes: ' answer
  if [[ "$answer" != Y ]]; then
    exit
  fi
fi
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
CYDIA_UPDATES=$(curl --silent "https://www.cydiaupdates.org/search/?s=$TWEAK_NAME&section=Tweaks&repo=all" | grep pack)
CYDIA_UPDATES=$( echo "$CYDIA_UPDATES" | grep -i $TWEAK_NAME)
if [ -z "$CYDIA_UPDATES" ]; then
echo "Tweak not found on cydia updates"
exit
fi
NUM_LINES=$(echo "$CYDIA_UPDATES" | wc -l)
if [[ "$NUM_LINES" != "1" ]]; then
  echo "Found more than one tweak that matches $TWEAK_NAME or $1 on cydia updates"
  echo "$CYDIA_UPDATES" | grep class=\"media-heading\" -n | sed 's@<.*><a.*\">@@' | sed 's@</a> <small>@ @' | sed 's@<.*@@'
  read -p "Choose the right tweak: " TWEAK_NUM
  CYDIA_UPDATES=$(echo "$CYDIA_UPDATES" | grep class=\"media-heading\" | sed "${TWEAK_NUM}q;d")
fi
TWEAK_VERSION=$(echo "$CYDIA_UPDATES" | awk '{ print $4 }' | sed 's@<small>@@' | sed 's@</.*@@')
echo Version: $TWEAK_VERSION
#https://www.cydiaupdates.org/pack/152802/
PACK=$(echo "$CYDIA_UPDATES" | awk '{ print $3 }' | sed 's@.*\"/@@' | sed 's@\".*@@')
DEB=$(curl --silent "https://www.cydiaupdates.org/$PACK" | grep deb | grep -v \<meta | head -n 1 | sed 's@.*href=\"@@' | sed 's@\">.*@@')
echo "Downloading..."
echo $DEB
#curl --silent "$DEB" > "$( echo $DEB | sed 's@.*/@@' )"
wget $DEB
