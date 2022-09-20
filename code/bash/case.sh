#!/bin/bash
read key
case $key in
 [a-z][a-z] | [a-z][0-9] | [9,0]* ) echo "Hello";;
esac
