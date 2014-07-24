#!/bin/bash
#oscdoc is part of https://github.com/7890/oscdoc

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#oschema_validate is part of https://github.com/7890/oschema
VAL_SCRIPT=oschema_validate

XSLDIR="$DIR"/oscdoc_xsl
RES_DIR=$DIR/oscdoc_res

XSL1="$XSLDIR"/oschema2html.xsl
XSL2="$XSLDIR"/oscdocindex.xsl
XSL3="$XSLDIR"/merge_ext_ids.xsl 

if [ $# -ne 2 ]
then
	echo "need params: <oscdoc XML file> <output directory>" >&2
	exit 1
fi

DEFINITION="$1"
OUTPUT_DIR="$2"

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

for tool in {xmlstarlet,sed,diff,bc,oschema_validate,oscdoc_aspect_map,dot,convert,oscdoc_aspect_graph}; \
	do checkAvail "$tool"; done


if [ ! -e "$DEFINITION" ]
then
	print_label "/!\\ XML file not found!"
	echo "$DEFINITION" >&2
	exit 1
fi

if [ ! -e "$OUTPUT_DIR" ]
then
	print_label "/!\\ output directory does not exist!"
	echo "$OUTPUT_DIR" >&2
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

if [ ! -e "$RES_DIR" ]
then

	print_label "/!\\ resources dir not found!"
	echo "$RES_DIR" >&2
	exit 1
fi

echo -n "checking if XML file is valid... " >&2

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

#assemble referenced asspects to generate a graph showing the
#"mount points"

#this is experimental and redundant and slow

#the meta/doc_origin must point to an existing file
#starting with http for remote or file://xxx (the latter only works
#locally for testing reasons)

print_label "creating aspect map...(this can take a while)"

aspect_map="`mktemp`"
oscdoc_aspect_map "$DEFINITION" > "$aspect_map"
ret=$?
if [ $ret -ne 0 ]
then
	print_label "/!\\ could not create aspect map!"
	rm -f "$aspect_map"
	exit 1
fi

#cat $aspect_map

graph_svg="`mktemp`"
graph_tl_png="`mktemp`"

##############################################
#prepare copy of needed resources for html page
mkdir -p "$OUTPUT_DIR"/res

GRAPH_SUCCESS=0

oscdoc_aspect_graph "$aspect_map" "$graph_svg".svg "$graph_tl_png".png
ret=$?
if [ $ret -ne 0 ]
then
	print_label "/!\\ could not create aspects graph. maybe no references"
	rm -f "$aspect_map"
	rm -f "$graph_svg"
	rm -f "$graph_tl_png"
	GRAPH_SUCCESS=0
#	exit 1
else
	mv "$aspect_map" "$OUTPUT_DIR"/res/aspect_map.xml
	mv "$graph_svg".svg "$OUTPUT_DIR"/res/aspects_graph.svg
	mv "$graph_tl_png".png "$OUTPUT_DIR"/res/aspects_graph_tl.png
	rm -f "$graph_svg"
	rm -f "$graph_tl_png"
	GRAPH_SUCCESS=1
fi

print_label "creating xml_data.js..."

#escape for js string ''
tmp_file="`mktemp`"
cat "$DEFINITION" | sed "s/'/\\\'/g" > "$tmp_file"

#put all on one line
(echo -n "xml='"; cat "$tmp_file"; echo -n "'") \
	| sed ':a;N;$!ba;s/\n/ /g' \
	> "$OUTPUT_DIR"/res/xml_data.js

rm -rf "$tmp_file"

######################################
#needs better error checking

print_label "creating divs.out... (this can take a while)"

#create basic html chunks (msg)
tmp_divs="`mktemp`"
xmlstarlet tr "$XSL1" "$DEFINITION" \
	| xmlstarlet sel -t -m "//msg" -c "." -n \
	> "$tmp_divs"

#create parseable xml file
tmp_divs_xml="`mktemp`"
(echo "<a>"; cat "$tmp_divs"; echo "</a>";) \
	| xmlstarlet fo > "$tmp_divs_xml"

#create list of external ids using base64 on prepared ($XSL1) concatenated fields
#this is about 10-100 times faster than xsl base64
tmp_ids="`mktemp`"
cat "$tmp_divs_xml" | xmlstarlet sel -t -m "//msg/id" -v "." -n \
	| sed -e 's/^[ \t]*//' | grep -v "^$" \
	| while read line
	do
		echo -n "$line" | base64 -w 0 -
		echo ""
	done \
	| sed 's/+/-/g' | sed 's/\//_/g' | sed 's/=/\./g' \
	| sed -e 's/^[ \t]*//' | grep -v "^$" \
	> "$tmp_ids"

id_count=`cat "$tmp_ids" | wc -l`
print_label "generated $id_count message ids."


#create parseable xml file with ids
tmp_ids_xml="`mktemp`"
(
echo "<a>"
	cat "$tmp_ids" \
	| while read line
	do
		echo "<idbase64>"$line"</idbase64>"
	done
echo "</a>"
) \
| xmlstarlet fo > "$tmp_ids_xml"

rm -f "$tmp_ids"

#total count of (could compare to #msg)
#id_count=`cat "$OUTPUT_DIR"/divs.ids | wc -l`

#merge messages with externally generated ids, do escaping in <pre>
xmlstarlet tr "$XSL3" -s ids="$tmp_ids_xml" "$tmp_divs_xml" \
	| sed 's/_LT_/</g' \
	| sed 's/_LTE_/<=/g' \
	| sed 's/_GT_/>/g' \
	| sed 's/_GTE_/>=/g' \
	| sed 's/_INF_/\&infin;/g' \
> "$tmp_divs"

rm -f "$tmp_ids_xml"

print_label "creating index.out..."

tmp_index="`mktemp`"
if [ $GRAPH_SUCCESS -eq 1 ]
then
	#params relative to index.html
	xmlstarlet tr "$XSL2" \
	-s aspects_graph_tl="res/aspects_graph_tl.png" \
	-s aspects_graph_svg="res/aspects_graph.svg" \
	"$DEFINITION" \
	> "$tmp_index"
else
	#params relative to index.html
	xmlstarlet tr "$XSL2" \
	"$DEFINITION" \
	> "$tmp_index"
fi

print_label "creating index.html..."

tmp_index_final="`mktemp`"
sed "/<!--DIVS-->/r" "$tmp_divs" "$tmp_index" > "$tmp_index_final"

print_label "cleaning up..."

mv "$tmp_index_final" "$OUTPUT_DIR/index.html"

rm -f "$tmp_divs"
rm -f "$tmp_index"

print_label "copying ressources to $OUTPUT_DIR..."

#copy other needed resources for html page and archive
cp "$RES_DIR"/* "$OUTPUT_DIR"/res
cp "$DEFINITION" "$OUTPUT_DIR"/res/unit.orig.xml

#echo "output:" >&2
echo "$OUTPUT_DIR/index.html" >&2
echo "oscdoc done." >&2

exit 
