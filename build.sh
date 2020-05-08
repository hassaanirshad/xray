#!/bin/bash

function getValueFromKey(){
	if [ ! -f "$1" ]
	then
		echo ""
	fi
        result=$( grep "^$2=" "$1" | cut -d '=' -f 2- )
        echo "$result"
}

testNum=$1

if [ -z "$testNum" ]
then
	echo "ERROR: Empty test number"
	exit 1
fi

srcDir="src/${testNum}"

if [ ! -d "$srcDir" ]
then
	echo "ERROR: No source directory: ${srcDir}"
	exit 1
fi

configDir="config/${testNum}"

if [ ! -d "$configDir" ]
then
	echo "ERROR: No config directory: ${configDir}"
	exit 1
fi

buildConfigFile="${configDir}/build"

keyName="cpp"; keyValue=$(getValueFromKey "$buildConfigFile" "$keyName"); if [ -z "$keyValue" ]; then echo "ERROR: Missing value for key: $keyName"; exit 1; fi;
cpp=$keyValue
keyName="instrument"; keyValue=$(getValueFromKey "$buildConfigFile" "$keyName"); if [ -z "$keyValue" ]; then echo "ERROR: Missing value for key: $keyName"; exit 1; fi;
instrument=$keyValue
keyName="instructionThreshold"; keyValue=$(getValueFromKey "$buildConfigFile" "$keyName");
instructionThreshold=$keyValue
keyName="attrFileName"; keyValue=$(getValueFromKey "$buildConfigFile" "$keyName");
attrFileName=$keyValue
keyName="srcFiles"; keyValue=$(getValueFromKey "$buildConfigFile" "$keyName");
srcFiles=$keyValue

compiler=
instrumentFlag=
instructionThresholdFlag=
attrFileFlag=
srcFilesList=

if [ "$cpp" = "0" ]
then
	compiler="clang-9"
elif [ "$cpp" = "1" ]
then
	compiler="clang++-9"
else
	echo "ERROR: Invalid boolean value for 'cpp': $cpp"
	exit 1
fi

if [ "$instrument" = "1" ]
then
	instrumentFlag="-fxray-instrument"
elif [ "$instrument" = "0" ]
then
	instrumentFlag=""
else
	echo "ERROR: Invalid boolean value for 'instrument': $instrument"
	exit 1
fi

if [ -z "$instructionThreshold" ]
then
	instructionThresholdFlag=""
elif [ "$instructionThreshold" -lt 0 ]
then
	echo "ERROR: Invalid negative value for 'instructionThreshold': $instructionThreshold"
	exit 1
else
	if [ -z "$instrumentFlag" ]
	then
		echo "ERROR: Incompatible flags. Cannot specify instructionThreshold without instrument"
		exit 1
	fi
	instructionThresholdFlag="-fxray-instruction-threshold=$instructionThreshold"
fi

if [ -z "$attrFileName" ]
then
	attrFileFlag=""
else
	if [ -z "$instrumentFlag" ]
	then
		echo "ERROR: Incompatible flags. Cannot specify attrFileName without instrument"
		exit 1
	fi
	attrFilePath="${configDir}/${attrFileName}"
	if [ ! -f "$attrFilePath" ]
	then
		echo "ERROR: attrFileName must be a file at $attrFilePath"
		exit 1
	else
		attrFileFlag="-fxray-attr-list=$attrFilePath"
	fi
fi

for f in $srcFiles
do
	if [ ! -f "$srcDir/$f" ]
	then
		echo "ERROR: No src file at path $srcDir/$f"
		exit 1
	fi
	srcFilesList="$srcFilesList $srcDir/$f"
done

binDir="bin/${testNum}"

mkdir -p "${binDir}"

if [ ! -d "${binDir}" ]
then
	echo "ERROR: Failed to create bin directory: ${binDir}"
	exit 1
fi

command="$compiler $instrumentFlag $instructionThresholdFlag $attrFileFlag -o ${binDir}/main $srcFilesList"

$command
