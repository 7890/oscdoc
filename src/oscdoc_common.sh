#!/bin/bash
#oscdoc is part of https://github.com/7890/oscdoc

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#oschema_validate is part of https://github.com/7890/oschema
VAL_SCRIPT=oschema_validate

XSL_DIR="$DIR"/oscdoc_xsl
XSL1="$XSL_DIR"/oschema2html.xsl
XSL2="$XSL_DIR"/oscdocindex.xsl
XSL3="$XSL_DIR"/merge_ext_ids.xsl 
#XSL4="$XSL_DIR"/rewrite_message_paths.xsl

RES_DIR="$DIR"/oscdoc_res

print_label()
{
	echo ".------" >&2
	echo "| $1" >&2
	echo "\______" >&2
}

if [ ! -e "$XSL1" ]
then
	print_label "/!\\ stylesheet not found!"
	echo "$XSL1" >&2
	exit 1
fi

if [ ! -e "$XSL2" ]
then
	print_label "/!\\ stylesheet not found!"
	echo "$XSL2" >&2
	exit 1
fi

if [ ! -e "$XSL3" ]
then
	print_label "/!\\ stylesheet not found!"
	echo "$XSL3" >&2
	exit 1
fi

#if [ ! -e "$XSL4" ]
#then
#	print_label "/!\\ stylesheet not found!"
#	echo "$XSL4" >&2
#	exit 1
#fi

if [ ! -e "$RES_DIR" ]
then

        print_label "/!\\ resources dir not found!"
        echo "$RES_DIR" >&2
        exit 1
fi

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

validate()
{
	echo -n "checking if XML file is valid... " >&2
	DEFINITION="$1"

	a=`"$VAL_SCRIPT" "$DEFINITION" 2>&1`
	ret=$?
	if [ $ret -ne 0 ]
	then
		echo "NO ($DEFINITION)" >&2
		echo "reason is given below:" >&2
		echo "$a" >&2
		exit 1
	else
		echo "yes ("$DEFINITION")" >&2
	fi
}
