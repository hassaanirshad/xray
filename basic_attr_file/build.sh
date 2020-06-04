#!/bin/bash

clang++-9 -fxray-instrument -fxray-instruction-threshold=1 -fxray-attr-list=xray_attr_file -o test test.cpp
