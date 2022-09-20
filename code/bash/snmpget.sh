#!/bin/bash
ip=10.218.33.2
var=$(snmpget -v 1 -c ghbitktw $ip iso.3.6.1.4.1.11195.1.5.5.1.4.2 -Oqv \
| sed -E "s/^[-|+][[:digit:]]{`(snmpget -v 1 -c ghbitktw $ip iso.3.6.1.4.1.11195.1.5.5.1.1.2 -Oqv)`}/&./g")
echo $var
