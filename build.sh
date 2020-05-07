#!/bin/bash

ithresh=1

#clang-9 -fxray-instrument -fxray-instruction-threshold="$ithresh" -fxray-attr-list=build.config -o bin/main src/main.c
#clang++-9 -fxray-instrument -fxray-log-args=1 -fxray-instruction-threshold="$ithresh" -fxray-attr-list=build.config -o bin/main src/main.c
#clang++-9 -fxray-instrument -fxray-log-args=1 -fxray-instruction-threshold="$ithresh" -o bin/main src/main.c
#clang++-9 -fxray-instrument -fxray-instruction-threshold="$ithresh" -fxray-attr-list=build.config -o bin/main src/main.c
#clang++-9 -fxray-instrument -fxray-instruction-threshold="$ithresh" -o bin/main src/main.c
clang++-9 -fxray-instrument -fxray-instruction-threshold="$ithresh" -o bin/main src/main.cpp
