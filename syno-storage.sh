#/bin/bash

function filesize() {
    OUT='/dev/null'
    [ "$#" == 0 ] && echo 'No number given' && return 1
    [ ! $(echo $1 | egrep -i '\-?[0-9]+') ] && echo 'Garbage data' && return 1

    if [ "$1" == '' -o "$1" -lt 0 ] 2>$OUT
    then
        printf '0 B'
        return 1
    else
        FSIZE=$1
    fi

    [ "$2" == '' ] && DECPTS=1 || DECPTS=$2

    KB=1024
    MB=1048576
    GB=1073741824
    TB=1099511627776
    PB=1125899906842624
    EB=1152921504606846976
    LM=9223372036854775807

    [ "$FSIZE" -le 0 ] 2>$OUT && echo "0 B" && return
    [ "$FSIZE" -lt $KB ] 2>$OUT && echo "$FSIZE B" && return
    [ "$FSIZE" -lt $MB ] 2>$OUT && echo "$(echo "scale=$DECPTS;$FSIZE/$KB"|bc) KB" && return
    [ "$FSIZE" -lt $GB ] 2>$OUT && echo "$(echo "scale=$DECPTS;$FSIZE/$MB"|bc) MB" && return
    [ "$FSIZE" -lt $TB ] 2>$OUT && echo "$(echo "scale=$DECPTS;$FSIZE/$GB"|bc) GB" && return
    [ "$FSIZE" -lt $PB ] 2>$OUT && echo "$(echo "scale=$DECPTS;$FSIZE/$TB"|bc) TB" && return
    [ "$FSIZE" -lt $EB ] 2>$OUT && echo "$(echo "scale=$DECPTS;$FSIZE/$PB"|bc) PB" && return
    [ "$FSIZE" -le $LM ] 2>$OUT && echo "$(echo "scale=$DECPTS;$FSIZE/$EB"|bc) EB" && return
    [ "$?" -ne '0' ] 2>$OUT && echo "Bad input" && return 1
}

user='USERNAME'
pass='PASSWORD'

ip='NAS ADDRESS'

auth=$(
	curl -ks "$ip/webapi/auth.cgi?api=SYNO.API.Auth&version=3&method=login&account=$user&passwd=$pass&session=FileStation&format=sid" | \
    python3 -c "import sys, json; print(json.load(sys.stdin)['data']['sid'])"
)

shares=$(curl -ks "$ip/webapi/entry.cgi?api=SYNO.FileStation.List&version=2&method=list_share&additional=volume_status&_sid=$auth" | jq -r '.["data"]["shares"][]|({name}+(.additional["volume_status"]))|{name,totalspace,freespace}|select(.name=="SHARE NAME")')

totalspace=$(echo ${shares} | jq '.["totalspace"]')
freespace=$(echo ${shares} | jq '.["freespace"]')

space=$(( 1000 * (totalspace - freespace) / totalspace ));

clear;
tput cup 0 0
tput setaf 7
tput rev
echo " TITLE TO BE SHOWN "
tput sgr0
tput cup 3 0
printf '[ ';

perc="$(( ($space + 50) / 100 * 2 ))";


printf '%0.s#' $(seq 1 $perc)

tput setaf 7
tput cup 3 22
printf ' ] ';
tput sgr0

case $space in
7[5-9][0-9]|8[0-9][0-9])
	tput setaf 3
	;;
9[0-9][0-9]|1000)
	tput setaf 1
	;;
esac;
printf "$(echo "scale=1;$space/10" | bc)"; echo "%";

echo
tput sgr0

tput setaf 7; tput cup 5 19; printf 'Used: '; tput sgr0; tput cup 5 25; printf "$(filesize $(( totalspace - freespace )) )\n"
tput setaf 7; tput cup 6 14; printf 'Available: '; tput sgr0; tput cup 6 25; printf "$(filesize $freespace)\n"
tput setaf 7; tput cup 7 18; printf 'Total: '; tput sgr0; tput cup 7 25; printf "$(filesize $totalspace)\n"

tput cup $(tput cols) 0;
printf "Press any key to continue"
while true; do
	read -rsn 1 key
		clear
		tput cup 0 0
		break
done