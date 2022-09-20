#!/bin/bash
#Подсматрел с инета, не разобрался как он работает.
i=172800
((sec=i%60, i/=60, min=i%60, hrs=i/60))
timestamp=$(printf "%d:%02d:%02d" $hrs $min $sec)
echo $timestamp
