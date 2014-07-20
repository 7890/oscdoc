#!/bin/bash
#oscdoc_aspect_graph is part of https://github.com/7890/oscdoc
#//tb/140719

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ $# -lt 2 ]
then
	echo "need params: <oscdoc aspect map XML file> <outfile name.svg> (<create thumbnail: 1>)" >&2
	echo "example: oscdoc_aspect_graph aspect_map.xml /tmp/a.svg"
	echo "example: oscdoc_aspect_graph aspect_map.xml /tmp/a.svg /tmp/a_thumb.png"
	exit 1
fi

ASPECT_MAP="$1"
OUTPUT_FILE="$2"

THUMBNAIL="0"
if [ $# -eq 3 ]
then
	THUMBNAIL="$3"
fi

THUMBNAIL_CMD="convert \"$OUTPUT_FILE\" -scale 800x \"$THUMBNAIL\""

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
		print_label "/!\\ tool \"$1\" not found. please install"
		echo "note: oschema_validate is part of https://github.com/7890/oschema" >&2
		exit 1
	fi
}

for tool in {xmlstarlet,sort,uniq,sed,dot,convert}; \
	do checkAvail "$tool"; done

if [ ! -e "$ASPECT_MAP" ]
then
	print_label "/!\\ XML file not found!" >&2
	echo "$ASPECT_MAP" >&2
	exit 1
fi

#needs schema
cat "$ASPECT_MAP" | xmlstarlet fo 2>&1 >/dev/null
ret=$?
if [ $ret -ne 0 ]
then
	print_label "/!\\ the aspect map was not valid."
	echo "$ASPECT_MAP" >&2
	exit 1
fi

#http://www.graphviz.org/doc/info/attrs.html
print_label "creating aspects digraph and render with graphviz dot as svg..."

#test if can be done
cat "$ASPECT_MAP" \
	| xmlstarlet sel -t -m "//aspect_map/aspect_map" -o '"' \
	-v "../@mount_at" -o "\n" -v "../@uri" \
	-o '" __LINK__  "' \
	-v "@mount_at" -o "\n" -v "@uri" -o '";' -n -b \
	1>/dev/null
ret=$?
if [ $ret -ne 0 ]
then
	print_label "/!\\ could not use given aspect map to create digraph!"
	exit 1
fi

tmp_file="`mktemp`"
#the same as tested above, now with added 
(echo "digraph aspects {"; \
	echo "node [shape=box];"; echo "graph [rankdir=LR];"; \
	cat "$ASPECT_MAP" \
		| xmlstarlet sel -t -m "//aspect_map/aspect_map" -o '"' \
		-v "../@mount_at" -o "\n" -v "../@uri" \
		-o '" __LINK__  "' \
		-v "@mount_at" -o "\n" -v "@uri" -o '";' -n -b \
	| sort | uniq | sed 's/__LINK__/->/g'; echo "}") \
> "$tmp_file"
#cat "$tmp_file"

#main output svg
cat "$tmp_file" \
| dot -Tsvg -o "$OUTPUT_FILE"
ret=$?
if [ $ret -ne 0 ]
then
	print_label "/!\\ generated dot file seems wrong!"
	rm -f "$tmp_file"
	exit 1
fi

rm -f "$tmp_file"

echo "$OUTPUT_FILE"

#thumbnail
if [ "$THUMBNAIL" != "0" ]
then
	print_label "creating thumbnail ($THUMBNAIL_CMD)..."
	eval "$THUMBNAIL_CMD"
	ret=$?
	if [ $ret -ne 0 ]
	then
		print_label "/!\\ could not create thumbnail!"
		exit 1
	fi
	echo "$THUMBNAIL"
fi

echo "oscdoc_aspect_graph done." >&2

exit
