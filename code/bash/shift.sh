#!/bin/bash
echo "Вы ввели аргументы в количестве $#"
echo "Все аргументы $@"
echo "Производим SHIFT"
shift
echo "Кколичество всех аргументов $#"
echo "Все аргументы $@"
