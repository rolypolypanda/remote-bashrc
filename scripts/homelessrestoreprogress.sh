#!/bin/bash

RESTCOUNT="$(ls -lah /root/xfer.$1 | grep .restore > restored.lst;wc -l restored.lst | awk '{ print $1 }')"
ACCTTOT="$(wc -l /root/xfer.$1/accounts.list | cut -d'/' -f1)"

echo -e "\nHello,\n\nCurrently there are $RESTCOUNT packages restored out of $ACCTTOT total.  We will continue to provide you with periodic updates.\n\nRegards,"
\rm -f restored.lst
