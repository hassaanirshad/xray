#!/bin/bash

config_file=run.config

if [ ! -z "$1" ]
then
	if [ ! -f "$1" ]
	then
		echo "Invalid config file:$1"
		exit -1
	else
		echo "Config file:$1"
		config_file="$1"
	fi
else
	# validate default
	if [ ! -f "$config_file" ]
	then
		echo "Invalid config file:$1"
		exit -1
	else
		echo "Config file:$config_file"
	fi
fi

function get_config_value(){
	result=$( grep "^$1=" "$config_file" | cut -d '=' -f 2- )
	echo "$result"
}

xkey="xray_mode"; xval=$(get_config_value "$xkey"); if [ -z "$xval" ]; then echo "Missing value: $xkey"; exit -1; fi;
xray_mode="$xval"; if [ "$xval" != "xray-basic" ] && [ "$xval" != "xray-fdr" ]; then echo "Invalid key-value: $xkey=$xval"; exit -1; fi
echo " - xray_mode:$xray_mode"

xkey="trace_it"; xval=$(get_config_value "$xkey"); if [ -z "$xval" ]; then echo "Missing value: $xkey"; exit -1; fi;
trace_it="$xval"; if [ "$xval" != "0" ] && [ "$xval" != "1" ]; then echo "Invalid key-value: $xkey=$xval"; exit -1; fi
echo " - trace_it:$trace_it"

xkey="log_prefix"; xval=$(get_config_value "$xkey"); if [ -z "$xval" ]; then echo "Missing value: $xkey"; exit -1; fi;
log_prefix="$xval"; if [ -z "$xval" ]; then echo "Invalid key-value: $xkey=$xval"; exit -1; fi
echo " - log_prefix:$log_prefix"

for f in `ls`;
do
	if [ -f "$f" ]
	then
		if echo "$f" | grep -q "$log_prefix"
		then
			rm "$f"
		fi
	fi
done

# starting

#export XRAY_OPTIONS="xray_logfile_base=$log_prefix patch_premain=true xray_mode=$xray_mode verbosity=1"
export XRAY_OPTIONS="xray_logfile_base=$log_prefix:patch_premain=true:xray_mode=$xray_mode:verbosity=1"

if [ "$xray_mode" == "xray-fdr" ]
then
	#export XRAY_FDR_OPTIONS="func_duration_threshold_us=0 grace_period_ms=1 no_file_flush=false"
	export XRAY_FDR_OPTIONS="func_duration_threshold_us=0 grace_period_ms=1 no_file_flush=true"
	#export XRAY_FDR_OPTIONS="func_duration_threshold_us=0:grace_period_ms=1:no_file_flush=false"
	#export XRAY_FDR_OPTIONS="func_duration_threshold_us=0:grace_period_ms=1:no_file_flush=true"
fi

comm="./bin/main 12345 world"

if [ "$trace_it" == "1" ]
then
	strace -f -s 1000000 $comm 2>&1 &> my.strace
else
	$comm
fi

