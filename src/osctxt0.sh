#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#oschema_validate is part of https://github.com/7890/oschema
VAL_SCRIPT=oschema_validate

XSLDIR="$DIR"/oscdoc_xsl

XSL1=$XSLDIR/osctxt0.xsl

if [ $# -ne 1 ]
then
	echo "need params: <oscdoc xml file>" >&2
	exit
fi

DEFINITION="$1"

print_label()
{
	echo ".------" >&2
	echo "| $1" >&2
	echo "\______" >&2
}

checkAvail()
{
	which "$1" >/dev/null 2>&1
	ret=$?
	if [ $ret -ne 0 ]
	then
		print_label "tool \"$1\" not found. please install"
		print_label "note: oschema_validate is part of https://github.com/7890/oschema"
		exit 1
	fi
}

for tool in {xmlstarlet,sed,diff,bc,oschema_validate}; \
	do checkAvail "$tool"; done


if [ ! -e "$DEFINITION" ]
then
        echo "xml file not found!" >&2
        echo "$DEFINITION" >&2
        exit 1
fi

if [ ! -e "$XSL1" ]
then
        echo "stylesheet not found!" >&2
        echo "$XSL1" >&2
        exit 1
fi

echo -n "checking if xml file is valid... " >&2

a=`"$VAL_SCRIPT" "$DEFINITION" 2>&1`
ret=$?
if [ "x$ret" != "x0" ]
then
	echo "NO ($DEFINITION)" >&2
	echo "reason is given below:" >&2
	echo "$a" >&2
	exit 1 >&2
else
	echo "yes ($DEFINITION)" >&2
fi

xmlstarlet tr "$XSL1" \
"$DEFINITION" \
	| sed 's/_LT_/</g' \
	| sed 's/_LTE_/<=/g' \
	| sed 's/_GT_/>/g' \
	| sed 's/_GTE_/>=/g' \
	| sed 's/_INF_/\infinity/g'
