#!/bin/bash

if [[ -z "$1" || ! "$1" =~ [A-Z]{8} ]]
then
  echo "missing ebox user code";
  exit 1;
fi

if [[ -z "$2" ]]
then
  echo "missing pushbullet Access-token";
  exit 1;
fi

if [[ -z "$3" ]]
then
echo "missing pushbullet device identification... sending to all...";
fi

exit 0;
# Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT=$(readlink -f "$0")
# Absolute path this script is in, thus /home/user/bin
SCRIPTPATH=$(dirname "$SCRIPT")

# put html in file
curl -s --data "actions=list&DELETE_lng=en&lng=en&code=$1" conso.ebox.ca > $SCRIPTPATH"/consommation.html";

#search html for total conso
consodata=`grep 'total_off' $SCRIPTPATH"/consommation.html" -n | awk -F"<br>" '{print $7}'`;

echo $consodata;

if [[ "$consodata" =~ [0-9]{1,3}\.?[0-9]{0,2}\ G$ ]]
then
	echo "good"
else
	consodata="Consommation indisponible"
	echo "bad"
fi

curl --header "Access-Token: $2" \
     --header 'Content-Type: application/json' \
     --data-binary "{\"device_iden\":\"$3\",\"body\":\"$consodata\",\"title\":\"Conso\",\"type\":\"note\"}" \
     --request POST \
     https://api.pushbullet.com/v2/pushes

