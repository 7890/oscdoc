#!/bin/bash
#osctxl0 is part of https://github.com/7890/oscdoc

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. "$DIR"/oscdoc_common.sh

if [ $# -lt 1 ]
then
	echo "need params: <oscdoc XML file>" >&2
	exit
fi

DEFINITION="$1"

SHOW_META=0

if [ $# -eq 2 ]
then
	SHOW_META=1
fi

for tool in {xmlstarlet,sed,diff,bc,oschema_validate}; \
	do checkAvail "$tool"; done

tmp_def="`mktemp`"
function clean_up1 
{
        #clean up
        rm -f "$tmp_def"
}
trap clean_up1 EXIT 

#re-cache/re-download/re-validate given file anytime
cat_local_or_remote_file "$DEFINITION" 1 > "$tmp_def"
ret=$?
if [ $ret -eq 0 ]
then
        DEFINITION="$tmp_def"
else
        print_label "/!\\ could not use given file ($DEFINITION)!"
        exit 1
fi

xmlstarlet tr "$XSL5" -s show_meta="$SHOW_META" \
"$DEFINITION" \
	| sed 's/_LT_/</g' \
	| sed 's/_LTE_/<=/g' \
	| sed 's/_GT_/>/g' \
	| sed 's/_GTE_/>=/g' \
	| sed 's/_INF_/\infinity/g'
