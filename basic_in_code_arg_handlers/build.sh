#!/bin/bash

clang++-9 -fxray-instrument -fxray-instruction-threshold=1 -o test test.cpp
