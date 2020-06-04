#!/bin/bash

function_address=$1

if [ ! -z "$function_address" ]
then
	function_name=$(nm --demangle test| grep "$function_address")
fi

echo "$function_name"
