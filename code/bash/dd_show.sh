#!/bin/bash
kill -USR1 `(ps -ax | grep " dd " | grep -v grep | sed 's/^ *//g' | cut -d " " -f1)`
