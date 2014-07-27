#!/bin/bash
#oscdoc_tree1 is part of https://github.com/7890/oscdoc
#//tb/140727

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. "$DIR"/oscdoc_common.sh

if [ $# -lt 1 ]
then
	echo "need params: <oscdoc XML file>" >&2
	exit 1
fi

#1
DEFINITION="$1"

for tool in {xmlstarlet,sed,diff,bc,wget,sort,uniq,rev,paste,oschema_validate,tree_dyna}; \
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

TMP_DIR_STRUCT="`mktemp -d`"
print_label "creating temporary directory tree in $TMP_DIR_STRUCT..."

cat "$tmp_def" | xmlstarlet sel -t -m "//message_in|//message_out" \
-v "@pattern" -n \
| sort | uniq | rev | cut -d "/" -f2- | rev | sort | uniq | grep -v "^$" \
| while read line; do mkdir -p "$TMP_DIR_STRUCT/$line"; done

print_label "creating JSON data..."

cur="`pwd`"; cd "$TMP_DIR_STRUCT"; tree_dyna -Jd; cd "$cur"
#needs error checking

rm -rf "$TMP_DIR_STRUCT"

#it's a tmp file
rm -f "$DEFINITION"

echo "oscdoc_tree1 done." >&2

exit
