#!/bin/sh

INPUT="$1"
test -z "$INPUT" && {
    echo Usage: $0 "<file>"
    exit 1
}

DATESTAMP="`date +"%Y%0m%0d"`"
RECIPACCESS=/etc/postfix/recipient_access
SENDERACCESS=/etc/postfix/sender_access
BKPRECIPACCESS="$RECIPACCESS"."$DATESTAMP"
BKPSENDERACCESS="$SENDERACCESS"."$DATESTAMP"
test -f "$BKPRECIPACCESS" || cp "$RECIPACCESS" "$BKPRECIPACCESS"
test -f "$BKPSENDERACCESS" || cp "$SENDERACCESS" "$BKPSENDERACCESS"

sed 's/ //g' "$INPUT" | sed '/^[[:space:]]*$/d' | sort | uniq |  sed 's/^\(.*\)$/\1 OK/' > "$INPUT.prepared"
cat "$RECIPACCESS.head" "$INPUT.prepared" > "$RECIPACCESS.new"
cat "$SENDERACCESS.head" "$INPUT.prepared" > "$SENDERACCESS.new"
mv "$RECIPACCESS.new" "$RECIPACCESS"
mv "$SENDERACCESS.new" "$SENDERACCESS"

echo DIFF for "$RECIPACCESS"
diff -u "$BKPRECIPACCESS" "$RECIPACCESS"
echo DIFF for "$SENDERACCESS"
diff -u "$BKPSENDERACCESS" "$SENDERACCESS"

postmap "$RECIPACCESS"
/etc/init.d/postfix reload
sleep 2
postmap "$SENDERACCESS"
/etc/init.d/postfix reload
