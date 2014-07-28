#!/bin/bash
#oscdoc_common is part of https://github.com/7890/oscdoc

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#oschema_validate is part of https://github.com/7890/oschema
VAL_SCRIPT=oschema_validate

XSL_DIR="$DIR"/oscdoc_xsl
XSL1="$XSL_DIR"/oschema2html.xsl
XSL2="$XSL_DIR"/oscdocindex.xsl
XSL3="$XSL_DIR"/merge_ext_ids.xsl 

XSL4="$XSL_DIR"/rewrite_message_paths.xsl
XSL5="$XSL_DIR"/osctxt0.xsl

#XSL5="$XSL_DIR"/add_messages.xsl

RES_DIR="$DIR"/oscdoc_res

CACHE_DIR="/tmp/oscdoc_cache"

function print_label()
{
	echo ".------" >&2
	echo "| $1" >&2
	echo "\______" >&2
}

if [ ! -e "$CACHE_DIR" ]
then
	print_label "file cache does not exist, creating... ($CACHE_DIR)"
	mkdir -p "$CACHE_DIR"
fi

if [ ! -e "$CACHE_DIR" ]
then
	print_label "/!\\ cache can not be used!"
	echo "$CACHE_DIR" >&2
	exit 1
fi

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

if [ ! -e "$XSL4" ]
then
	print_label "/!\\ stylesheet not found!"
	echo "$XSL4" >&2
	exit 1
fi

if [ ! -e "$XSL5" ]
then
	print_label "/!\\ stylesheet not found!"
	echo "$XSL5" >&2
	exit 1
fi

#if [ ! -e "$XSL5" ]
#then
#	print_label "/!\\ stylesheet not found!"
#	echo "$XSL5" >&2
#	exit 1
#fi

if [ ! -e "$RES_DIR" ]
then

        print_label "/!\\ resources dir not found!"
        echo "$RES_DIR" >&2
        exit 1
fi

function checkAvail()
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

function validate()
{
	#echo -n "checking if XML file is valid... " >&2
	print_label "checking if oschema instance file is valid... "
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

function validate_aspect_map()
{
	#dummy, no schema
	ASPECT_MAP="$1"

	if [ ! -e "$ASPECT_MAP" ]
		then
		echo "aspect map file not found!" >&2
		echo "$ASPECT_MAP" >&2
		exit 1
	fi

	print_label "checking if aspect map file is valid (loosely)... "

	cat "$ASPECT_MAP" | xmlstarlet fo 2>&1 >/dev/null
	ret=$?
	if [ $ret -ne 0 ]
	then
		echo "the aspect map was not valid." >&2
		exit 1
	fi
}

#1: tag 2: file to enclose
function enclose_xml()
{
	(echo "<$1>"; cat "$2"; echo "</$1>";)
}

function remove_leading_and_empty()
{
	sed -e 's/^[ \t]*//' | grep -v "^$"
}

#translate a base64 encoded string so it can be used in attributes
#+/=
#-_.
function translate_base64_to_attribute()
{
	sed 's/+/-/g' | sed 's/\//_/g' | sed 's/=/\./g'
}

function replace_math_placeholders()
{
	sed 's/_LT_/</g' \
	| sed 's/_LTE_/<=/g' \
	| sed 's/_GT_/>/g' \
	| sed 's/_GTE_/>=/g' \
	| sed 's/_INF_/\&infin;/g'
}

function cat_local_or_remote_file()
{
	DEFINITION="$1"
	RE_CACHE="$2"

	#test if url to download
	doc_origin=""
	remote_test="`echo "$DEFINITION" | grep '^http.*'`"
	ret=$?
	if [ $ret -eq 0 ]
	then
		doc_origin="$DEFINITION"

		cache_hash=`echo -n "$doc_origin" | base64 - \
			| translate_base64_to_attribute`

		#print_label "cache hash for $doc_origin:"
		#echo "$cache_hash" >&2
		#ls -1 "$CACHE_DIR"/"$cache_hash" >&2

		#remove from cache to re-cache
		if [ x"$RE_CACHE" != "x" ]
		then
			rm -f "$CACHE_DIR"/"$cache_hash"
		fi

		if [ -e "$CACHE_DIR"/"$cache_hash" ]
		then
			print_label "found $doc_origin in cache"
			echo "$CACHE_DIR"/"$cache_hash" >&2
		else
			print_label "fetching $doc_origin"

			fetch_tmp="`mktemp`"
			wget -q -O "$fetch_tmp" "$doc_origin"
			ret=$?
			if [ $ret -ne 0 ]
			then
				print_label "/!\\ error wgetting remote file $doc_origin"
				rm -f "$fetch_tmp"
				return 1
			fi

			validate "$fetch_tmp"

			print_label "putting $doc_origin to cache"
			mv "$fetch_tmp" "$CACHE_DIR"/"$cache_hash"
		fi

		cat "$CACHE_DIR"/"$cache_hash"
	else
		#rewrite file:// uris
		file_uri_test="`echo \"$DEFINITION\" | grep '^file://.*'`"
		ret=$?
		if [ $ret -eq 0 ]
		then
			file="`echo \"$DEFINITION\" | cut -d"/" -f3-`"
			DEFINITION="$file"
		fi

		if [ ! -e "$DEFINITION" ]
		then
			print_label "/!\\ XML file not found!"
			echo "$DEFINITION" >&2
			return 1
		fi

		cache_hash=`echo -n "$DEFINITION" | base64 - \
			| translate_base64_to_attribute`

		#print_label "cache hash for $DEFINITION:"
		#echo "$cache_hash" >&2

		#remove from cache to re-cache
		if [ x"$RE_CACHE" != "x" ]
		then
			rm -f "$CACHE_DIR"/"$cache_hash"
		fi

		if [ -e "$CACHE_DIR"/"$cache_hash" ]
		then
			print_label "found $DEFINITION in cache"
			echo "$CACHE_DIR"/"$cache_hash" >&2
		else
			validate "$DEFINITION"
			print_label "putting $DEFINITION to cache"
			cp "$DEFINITION" "$CACHE_DIR"/"$cache_hash"
		fi

		cat "$DEFINITION"
	fi
	return 0
}
