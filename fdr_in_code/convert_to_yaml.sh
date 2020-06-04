#!/bin/bash

log_file=`ls | grep xlog_test_test`

if [ ! -f "$log_file" ]
then
	echo "No file with prefix: xlog_test_test"
	exit -1
fi

llvm-xray-9 convert -f yaml -y -m test "$log_file" 2>/dev/null
