#!/bin/bash
#oscdoc_aspect_map is part of https://github.com/7890/oscdoc
#//tb/140719

#this is really slow when a lot of aspects are used
#it's not optimized to speed yet

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. "$DIR"/oscdoc_common.sh

if [ $# -lt 1 ]
then
	echo "need params: <oscdoc XML file>" >&2
	exit 1
fi

SELF=oscdoc_aspect_map
#echo "called with args $@" >&2

#1
DEFINITION="$1"

#2 (optional, used in recursive calls)
MOUNT_AT="/*"
if [ $# -gt 1 ]
then
	MOUNT_AT="$2"
fi

#3 (optional, used in recursive calls)
XPATH=""
if [ $# -gt 2 ]
then
	XPATH="$3"
fi

DIRECTION=""
#4 (optional, used in recursive calls)
if [ $# -gt 3 ]
then
	DIRECTION="$4"
fi

#if no direction given, do for both in/out
#(calling this script with just an instance document as argument)
if [ x"$DIRECTION" = x ]
then
	echo "<root>"
		#all message_in aspects
		DIRECTION="in"
		"$SELF" "$DEFINITION" "$MOUNT_AT" "$XPATH" "$DIRECTION"
		ret=$?
		if [ $ret -ne 0 ]
		then
			print_label "/!\\ error in recursive call in oscdoc_aspect_map"
			exit 1
		fi
		#set for all message_out aspects
		DIRECTION="out"
		"$SELF" "$DEFINITION" "$MOUNT_AT" "$XPATH" "$DIRECTION"
		ret=$?
		if [ $ret -ne 0 ]
		then
			print_label "/!\\ error in recursive call in oscdoc_aspect_map"
			exit 1
		fi
	echo "</root>"

	exit
fi

for tool in {xmlstarlet,sed,diff,bc,wget,oschema_validate,oscdoc_aspect_map}; \
	do checkAvail "$tool"; done

#operate always on tmp file
tmp_def="`mktemp`"
cat_local_or_remote_file "$DEFINITION" > "$tmp_def"
ret=$?
if [ $ret -ne 0 ]
then
	print_label "/!\\ error reading $DEFINITION!"
	exit 1
fi

DEFINITION="$tmp_def"

#file should be available and valid from here on

#uri as per doc content
URI="`cat "$DEFINITION" \
	| xmlstarlet sel -t -m "//meta/uri" \
	-v "." -n`"

#doc_origin as per doc content
DO="`cat "$DEFINITION" \
	| xmlstarlet sel -t -m "//meta/doc_origin" \
	-v "." -n`"

#start xml output
echo -n "<aspect_map direction=\""$DIRECTION"\" mount_at=\"$MOUNT_AT\" uri=\"$URI\" doc_origin=\"$DO\" xpath=\"$XPATH\""

#must process in/out seperately to avoid resulting doubles for some cases
#get all aspects of given oschema instance
referenced_origins="`mktemp`"
cat "$DEFINITION" \
	| xmlstarlet sel -t -m "//message_${DIRECTION}/aspect" \
	-v "doc_origin" -o " " -v "../@pattern" -o " " \
	-v "substring-after(name(..),'_')" -o " " -v "xpath" -n \
> "$referenced_origins"

cat "$referenced_origins" | grep -v "^$" > "$referenced_origins"_
mv "$referenced_origins"_ "$referenced_origins"

#it's a tmp file
rm -f "$DEFINITION"

#cat "$referenced_origins"

COUNT=`cat "$referenced_origins" | wc -l`
#when no references found, no children
if [ $COUNT -eq 0 ]
then
	#close element <aspect_map ... />
	echo "/>"
else
	#keep open <aspect_map>...
	echo ">"
fi

#recursively process every aspect
cat "$referenced_origins" \
	| while read line
	do
		origin=`echo "$line" | cut -d" " -f1`
		pattern=`echo "$line" | cut -d" " -f2`
		DIRECTION=`echo "$line" | cut -d" " -f3`
		xpath=`echo "$line" | cut -d" " -f4-`

		#call self with local (possibly downloaded) file
		"$SELF" "$origin" "$pattern" "$xpath" "$DIRECTION"
		ret=$?
		if [ $ret -ne 0 ]
		then
			print_label "/!\\ error in recursive call in oscdoc_aspect_map"
			#echo "$SELF" "$fetch_tmp" "$MOUNT_AT" "$XPATH" "$DIRECTION" >&2
			rm -f "$referenced_origins"
			#http://stackoverflow.com/questions/18359777/bash-exit-doesnt-exit
			exit 1
		fi
	done
	[ $? == 1 ] && exit 1;

#close (possibly nested) aspect
if [ $COUNT -ne 0 ]
then
	echo "</aspect_map>"
fi

rm -f "$referenced_origins"

echo "oscdoc_aspect_map done." >&2

exit
