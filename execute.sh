#!/bin/bash

config_file=run.config

# validate default
if [ ! -f "$config_file" ]
then
	echo "Invalid config file:$1"
	exit -1
#else
	#echo "Config file:$config_file"
fi

function get_config_value(){
        result=$( grep "^$1=" "$config_file" | cut -d '=' -f 2- )
        echo "$result"
}

xkey="log_prefix"; xval=$(get_config_value "$xkey"); if [ -z "$xval" ]; then echo "Missing value: $xkey"; exit -1; fi;
log_prefix="$xval"; if [ -z "$xval" ]; then echo "Invalid key-value: $xkey=$xval"; exit -1; fi
#echo " - log_prefix:$log_prefix"

log_file=`ls | grep $log_prefix`

#echo "File: $log_file"
#echo "Subcommand: $1"

if [ ! -f "$log_file" ]
then
	echo "No file with prefix: $log_prefix"
	exit -1
fi

if [ "$1" == "account" ]
then
	llvm-xray-9 account "$log_file" -top=10 -sort=sum -sortorder=dsc -instr_map ./bin/main 2>/dev/null
elif [ "$1" == "stack" ]
then
	llvm-xray-9 stack "$log_file" -instr_map ./bin/main 2>/dev/null
elif [ "$1" == "convert" ]
then
	llvm-xray-9 convert -f yaml -y -m ./bin/main "$log_file" 2>/dev/null
else
	echo "UNKNOWN Subcommand. Valid: account|stack|convert"
fi
