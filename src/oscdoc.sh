#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#oschema_validate is part of https://github.com/7890/oschema
VAL_SCRIPT=oschema_validate
XSL1=$DIR/oschema2html.xsl
XSL2=$DIR/oscdocindex.xsl
RES_DIR=$DIR/oscdoc_res

if [ $# -ne 2 ]
then
	echo "need params: <oscdoc xml file> <output directory>"
	exit
fi

DEFINITION="$1"
OUTPUT_DIR="$2"

print_label()
{
	echo ".------"
	echo "| $1"
	echo "\______"
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
        echo "$DEFINITION"
        exit 1
fi

if [ ! -e "$OUTPUT_DIR" ]
then
        echo "output directory does not exist!" >&2
        echo "$OUTPUT_DIR"
        exit 1
fi

if [ ! -e "$XSL1" ]
then
        echo "stylesheet not found!" >&2
        echo "$XSL1"
        exit 1
fi

if [ ! -e "$XSL2" ]
then
        echo "stylesheet not found!" >&2
        echo "$XSL2"
        exit 1
fi

if [ ! -e "$RES_DIR" ]
then
        echo "ressources dir not found!" >&2
        echo "$RES_DIR"
        exit 1
fi

echo -n "checking if xml file is valid... "

a=`"$VAL_SCRIPT" "$DEFINITION" 2>&1`
ret=$?
if [ "x$ret" != "x0" ]
then
	echo "NO"
	echo "reason is given below:"
	echo "$a"
	exit 1
else
	echo "yes"
fi

echo "creating xml_data.js..."

cat "$DEFINITION" | sed "s/'/\\\'/g" > "$OUTPUT_DIR"/tmp.def

(echo -n "xml='"; cat "$OUTPUT_DIR"/tmp.def; echo -n "'") \
	| sed ':a;N;$!ba;s/\n/ /g' \
	> "$OUTPUT_DIR"/xml_data.js

rm -f "$OUTPUT_DIR"/tmp.def

echo "creating divs.out..."

xmlstarlet tr "$XSL1" \
"$DEFINITION" \
	| xmlstarlet sel -t -m "//msg" -e div -a id \
	-v "@id" \
	-b -a class -o "hidden_content" -b -c "." -b -n \
	| sed 's/_LT_/</g' \
	| sed 's/_LTE_/<=/g' \
	| sed 's/_GT_/>/g' \
	| sed 's/_GTE_/>=/g' \
	| sed 's/_INF_/\&infin;/g' \
	> "$OUTPUT_DIR"/divs.out

echo "creating index.out..."

xmlstarlet tr "$XSL2" \
"$DEFINITION" \
> "$OUTPUT_DIR"/index.out

echo "creating index.html..."

sed "/<!--DIVS-->/r "$OUTPUT_DIR"/divs.out" "$OUTPUT_DIR"/index.out > "$OUTPUT_DIR"/index.html
#| sed '/<!--DIVS-->/r div_.out' -

echo "cleaning up..."

rm "$OUTPUT_DIR"/divs.out
rm "$OUTPUT_DIR"/index.out

echo "copying ressources to $OUTPUT_DIR..."

#copy needed resources
mkdir -p "$OUTPUT_DIR"/res

mv "$OUTPUT_DIR"/xml_data.js "$OUTPUT_DIR"/res

cp "$RES_DIR"/* "$OUTPUT_DIR"/res

echo "output:"
echo "$OUTPUT_DIR/index.html"
echo "done oscdoc"
