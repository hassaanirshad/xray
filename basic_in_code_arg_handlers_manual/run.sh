#!/bin/bash

rm -f xlog_test_test.*
rm -f xmanual.log

#XRAY_OPTIONS="patch_premain=true:verbosity=1:xray_mode=xray-basic:xray_logfile_base=xlog_test_" ./test
XRAY_OPTIONS="patch_premain=true:verbosity=1:xray_logfile_base=xlog_test_" ./test
