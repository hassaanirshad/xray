#!/bin/bash

rm -f xlog_test_test.*

XRAY_OPTIONS="patch_premain=true:verbosity=1:xray_logfile_base=xlog_test_" ./test
